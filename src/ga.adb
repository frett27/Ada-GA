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

with Ada.Text_Io;
use Ada.Text_Io;

package body Ga is


   function "<" (Left , Right : Evaluated_Chromosome)
                return Boolean is
   begin
      -- desc ordering ...
      return Left.V > Right.V;
   end;


   procedure Add(P : in out Pop_Type ; C : in Chromosome) is
   begin
      declare
         E : Evaluated_Chromosome;
      begin
         E.C := C;
         E.V := Eval(E.C);
         P.Pop(P.Chromosome_Count + 1) := E;
         P.Chromosome_Count := Natural'Succ(P.Chromosome_Count);
      end;
   end;


   function Create_Random_Pop return Pop_Type is
      New_Pop : Pop_Type;
   begin
      for I in 1..Pop_Size loop
         Add(New_Pop, Random);
      end loop;
      return New_Pop;
   end;

   -- look the best chromosome of the population
   -- this is a o(n) implementation
   function Best_Chromosome( P : Pop_Type )
                           return Chromosome is
   begin
      if P.Chromosome_Count = 0 then
         raise Empty_Population;
      end if;

      declare
         J : Positive := 1;
      begin
         for I in 1..P.Chromosome_Count loop
            if P.Pop(I).V > P.Pop(j).V then
               J := I;
            end if;
         end loop;
         return P.Pop(J).C;
      end;
   end;

   -------------------------------------------------------------
   --
   --  new generation sub routines ....
   --


   -- random package for each random operation on GA ....




   Selection_Wheel_Random : Ada.Numerics.Float_Random.Generator;
   Crossover_Random : Ada.Numerics.Float_Random.Generator;
   Mutation_Random : Ada.Numerics.Float_Random.Generator;


   -- create a new array sorted by the inverted order of the chromosome value 
   function Sort_Chromosome_Array( A : Evaluated_Chromosome_Array )
                                 return Evaluated_Chromosome_Array is
      New_Arr : Evaluated_Chromosome_Array := A;

      procedure Sort is
         new Ada.Containers.Generic_Array_Sort
        (Index_Type => Positive,
         Element_Type => Evaluated_Chromosome,
         Array_Type => Evaluated_Chromosome_Array);

   begin
      Sort(New_Arr);
      return New_Arr;
   end;




   -- cree une nouvelle g?n?ration ? partir d'une population
   function New_Generation ( P : in Pop_Type )
                           return Pop_Type
   is
      use Ada.Numerics.Float_Random;

      New_Pop : Pop_Type;

      function Sum(ECA : Evaluated_Chromosome_Array) return Float
      is
         V : Float := 0.0;
      begin
         for I in Eca'Range loop
         V := V + Eca(I).V;
         end loop;
         return V;
      end;

      -- selection
      function Wheel_Select (Sorted_Array : in Evaluated_Chromosome_Array)
                           return Evaluated_Chromosome is
         C : Float := Random(Selection_Wheel_Random) * Sum(Sorted_Array);
         F : Float := Sorted_Array(Sorted_Array'First).V;
         I : Positive := Sorted_Array'First;
      begin

         while I < Sorted_Array'Last and then F <= C loop
            I := I + 1;
            F := F + Sorted_Array(I).V;
         end loop;

         if I > Sorted_Array'Last then
            I := Sorted_Array'Last;
         end if;

         return Sorted_Array(I);

      end;

      --
      -- improve the local search of solutions
      --
      procedure Normalize(Sorted_Array : in out Evaluated_Chromosome_Array) is
      begin
         for I in Sorted_Array'Range loop
            Sorted_Array(I).V := Sorted_Array(I).V - Sorted_Array(Sorted_Array'Last).V;
         end loop;
      end;


   begin
      if P.Chromosome_Count = 0 then
         -- no elements
         return New_Pop;
      end if;

      declare
         Last_Index_Conservation : Positive :=
           Natural(Pop_Conservation * float(P.Chromosome_Count - 1) + 1.0);

         SA : Evaluated_Chromosome_Array :=
           Sort_Chromosome_Array(P.Pop(1..Last_Index_Conservation));
      begin

         Normalize(Sa);

         for I in 1..Pop_Size / 2 loop
            declare
               EC1 : Evaluated_Chromosome := Wheel_Select(Sa);
               EC2 : Evaluated_Chromosome := Wheel_Select(Sa);
            begin

               -- cross over ...
               if Random(Crossover_Random) < Crossover_Ratio then
                  declare
                     Cout1, Cout2 : Chromosome;
                  begin
                     Cross_Over(Ec1.C, Ec2.C, Cout1, Cout2);
                     Ec1.C := Cout1;
                     Ec2.C := Cout2;
                  end;
               end if;


               -- mutate 1

               if Random(Mutation_Random) < Mutation_Ratio then
                  Ec1.C := Mutate(Ec1.C);
               end if;

               -- mutate 2

               if Random(Mutation_Random) < Mutation_Ratio then
                  Ec2.C := Mutate(Ec2.C);
               end if;

               Add(New_Pop, Ec1.C);
               Add(New_Pop, Ec2.C);

            end;

         end loop;

      end;
      return New_Pop;
   end;

end Ga;
