-------------------------------------------------------------------------------
--                     Generic Algorithm Library Tools                      --
--                                                                          --
--                         Copyright (C) 2008-2013                          --
--                                                                          --
--  Authors: Patrice Freydiere                                              --
--                                                                          --
--  This library is free software; you can redistribute it and/or modify    --
--  it under the terms of the GNU General Public License as published by    --
--  the Free Software Foundation; either version 2 of the License, or (at   --
--  your option) any later version.                                         --
--                                                                          --
--  This library is distributed in the hope that it will be useful, but     --
--  WITHOUT ANY WARRANTY; without even the implied warranty of              --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       --
--  General Public License for more details.                                --
--                                                                          --
--  You should have received a copy of the GNU General Public License       --
--  along with this library; if not, write to the Free Software Foundation, --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.          --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Numerics.Float_Random;
with Ada.Containers.Generic_Array_Sort;

package body Ga.Population is

   function "<" (Left, Right : Evaluated_Gene) return Boolean is
   begin
      -- desc ordering ...
      return Left.V > Right.V;
   end "<";

   procedure Add (P : in out Pop_Type; C : in Gene) is
   begin
      declare
         E : Evaluated_Gene;
      begin
         E.C                            := C;
         E.V                            := Eval (E.C);
         P.Pop (P.Gene_Count + 1) := E;
         P.Gene_Count             := Natural'Succ (P.Gene_Count);
      end;
   end Add;

   function Create_Random_Pop return Pop_Type is
      New_Pop : Pop_Type;
   begin
      for I in 1 .. Pop_Size loop
         Add (New_Pop, Random);
      end loop;
      return New_Pop;
   end Create_Random_Pop;

   -- look the best chromosome of the population
   -- this is a o(n) implementation
   function Best_Gene (P : Pop_Type) return Gene is
   begin
      if P.Gene_Count = 0 then
         raise Empty_Population;
      end if;

      declare
         J : Positive := 1;
      begin
         for I in 1 .. P.Gene_Count loop
            if P.Pop (I).V > P.Pop (J).V then
               J := I;
            end if;
         end loop;
         return P.Pop (J).C;
      end;
   end Best_Gene;

   -------------------------------------------------------------
   --
   --  new generation sub routines ....
   --

   -- random package for each random operation on GA ....

   -- Random generator for selection wheel
   Selection_Wheel_Random : Ada.Numerics.Float_Random.Generator;

   -- Random Generator for CrossOver
   Crossover_Random : Ada.Numerics.Float_Random.Generator;

   -- Random Generator for Mutation
   Mutation_Random : Ada.Numerics.Float_Random.Generator;

   -- create a new array sorted by the inverted order of the chromosome value
   function Sort_Gene_Array
     (A    : Evaluated_Gene_Array)
      return Evaluated_Gene_Array
   is
      New_Arr : Evaluated_Gene_Array := A;

      procedure Sort is new Ada.Containers.Generic_Array_Sort (
         Index_Type   => Positive,
         Element_Type => Evaluated_Gene,
         Array_Type   => Evaluated_Gene_Array);

   begin
      Sort (New_Arr);
      return New_Arr;
   end Sort_Gene_Array;

   -- make evolve a population
   function New_Generation (P : in Pop_Type) return Pop_Type is
      use Ada.Numerics.Float_Random;

      New_Pop : Pop_Type;

      function Sum (ECA : Evaluated_Gene_Array) return Float is
         V : Float := 0.0;
      begin
         for I in ECA'Range loop
            V := V + ECA (I).V;
         end loop;
         return V;
      end Sum;

      -- selection
      function Wheel_Select
        (Sorted_Array : in Evaluated_Gene_Array)
         return         Evaluated_Gene
      is
         C : Float    :=
           Random (Selection_Wheel_Random) * Sum (Sorted_Array);
         F : Float    := Sorted_Array (Sorted_Array'First).V;
         I : Positive := Sorted_Array'First;
      begin

         while I < Sorted_Array'Last and then F <= C loop
            I := I + 1;
            F := F + Sorted_Array (I).V;
         end loop;

         if I > Sorted_Array'Last then
            I := Sorted_Array'Last;
         end if;

         return Sorted_Array (I);

      end Wheel_Select;

      --
      -- improve the local search of solutions
      --
      procedure Normalize
        (Sorted_Array : in out Evaluated_Gene_Array)
      is
      begin
         for I in Sorted_Array'Range loop
            Sorted_Array (I).V := Sorted_Array (I).V -
                                  Sorted_Array (Sorted_Array'Last).V;
         end loop;
      end Normalize;

   begin
      if P.Gene_Count = 0 then
         -- no elements
         return New_Pop;
      end if;

      declare
         Last_Index_Conservation : Positive :=
           Natural (Pop_Conservation * Float (P.Gene_Count - 1) + 1.0);

         Selected_Population : Evaluated_Gene_Array :=
           Sort_Gene_Array (P.Pop (1 .. Last_Index_Conservation));
      begin

         Normalize (Selected_Population);

         for I in 1 .. Pop_Size / 2 loop
            declare
               EC1 : Evaluated_Gene :=
                 Wheel_Select (Selected_Population);
               EC2 : Evaluated_Gene :=
                 Wheel_Select (Selected_Population);
            begin

               -- cross over ...
               if Random (Crossover_Random) < Crossover_Ratio then
                  declare
                     Cout1, Cout2 : Gene;
                  begin
                     Cross_Over (EC1.C, EC2.C, Cout1, Cout2);
                     EC1.C := Cout1;
                     EC2.C := Cout2;
                  end;
               end if;

               -- mutate 1

               if Random (Mutation_Random) < Mutation_Ratio then
                  EC1.C := Mutate (EC1.C);
               end if;

               -- mutate 2

               if Random (Mutation_Random) < Mutation_Ratio then
                  EC2.C := Mutate (EC2.C);
               end if;

               Add (New_Pop, EC1.C);
               Add (New_Pop, EC2.C);

            end;

         end loop;

      end;
      return New_Pop;
   end New_Generation;

end Ga.Population;
