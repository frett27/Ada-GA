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

with Ada.Text_IO;

package body Ga.Population is

   function "<" (Left, Right : Evaluated_Gene) return Boolean is
   begin
      -- desc ordering ...
      return Left.V > Right.V;
   end "<";

   -- create a new array sorted by the inverted order of the chromosome value
   function Sort_Gene_Array
     (A    : Evaluated_Gene_Array)
      return Evaluated_Gene_Array
   is
      New_Arr : Evaluated_Gene_Array := A;

      procedure Sort is new Ada.Containers.Generic_Array_Sort (
         Index_Type   => Pop_Range,
         Element_Type => Evaluated_Gene,
         Array_Type   => Evaluated_Gene_Array);

   begin
      Sort (New_Arr);
      return New_Arr;
   end Sort_Gene_Array;


   procedure Add (P : in out Pop_Type; C : in Gene; I : Pop_Range) is
   begin
      declare
         E : Evaluated_Gene := (C => C, V => Eval (C));
      begin
         P.Pop (I) := E;
         P.Pop_Sum := P.Pop_Sum + E.V;
      end;
   end Add;

   function Create_Random_Pop return Pop_Type is
      New_Pop : Pop_Type;
   begin
      for I in Pop_Range loop
         Add (New_Pop, Random, I);
      end loop;
	  -- sorting
	  New_Pop.Pop := Sort_Gene_Array(New_Pop.Pop);
      return New_Pop;
   end Create_Random_Pop;

   -- look the best chromosome of the population
   -- As the population is always sorted in descendent order, 
   -- the first item is always the best one
   function Best_Gene (P : Pop_Type) return Gene is
   begin
	  return P.Pop(P.Pop'First).C;
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

   function Normalize_And_Compute_Sum (P : in Pop_Type) return Pop_Type is
      Last_Element_Value : Float    := P.Pop (P.Pop'Last).V;
      New_Pop            : Pop_Type := P;
   begin
      New_Pop.Pop_Sum := 0.0;
      for I in P.Pop'Range loop
         New_Pop.Pop (I)   := P.Pop (I);
         New_Pop.Pop (I).V := P.Pop (I).V - Last_Element_Value;
         New_Pop.Pop_Sum   := New_Pop.Pop_Sum + New_Pop.Pop (I).V;
      end loop;
      return New_Pop;
   end Normalize_And_Compute_Sum;

   -- selection
   function Wheel_Select (A : in Pop_Type) return Evaluated_Gene is
      use Ada.Numerics.Float_Random;
      use Ada.Text_IO;
      C : Float    :=
        Random (Selection_Wheel_Random) * A.Pop_Sum * Pop_Conservation;
      F : Float    := A.Pop (A.Pop'First).V;
      I : Positive := A.Pop'First;
   begin
      Put_Line
        ("Select " & Float'Image (C) & " in " & Float'Image (A.Pop_Sum));

      while I <= A.Pop'Last and then F <= C loop
         I := I + 1;
         F := F + A.Pop (I).V;
      end loop;
      Put_Line ("Element selected " & Natural'Image (I));
      return A.Pop (I);

   end Wheel_Select;

   procedure Dump (Popu : in Pop_Type) is
      use Ada.Text_IO;
   begin
      for I in Popu.Pop'Range loop
         Put_Line
           (" e " &
            Natural'Image (I) &
            " :" &
            Image (Popu.Pop (I).C) &
            " -> " &
            Float'Image (Popu.Pop (I).V));
      end loop;
   end Dump;

   -- make evolve a population
   function New_Generation (P : in Pop_Type) return Pop_Type is
      use Ada.Numerics.Float_Random;
      use Ada.Text_IO;

      New_Pop    : Pop_Type;
      Normalized : Pop_Type := Normalize_And_Compute_Sum(P);

   begin

      for I in 1 .. Pop_Size / 2 loop
         declare
            EC1    : Evaluated_Gene := Wheel_Select (Normalized);
            EC2    : Evaluated_Gene := Wheel_Select (Normalized);
            Child1 : Gene           := EC1.C;
            Child2 : Gene           := EC2.C;
         begin

            -- cross over ...
            if Random (Crossover_Random) < Crossover_Ratio then
               Cross_Over (Child1, Child2, Child1, Child2);
            end if;

            -- mutate 1

            if Random (Mutation_Random) < Mutation_Ratio then
			   Put_Line("Mutate :" & Image(Child1));
               Child1 := Mutate (Child1);
			   Put_Line(" Mutate result :" & Image(Child1));
            end if;

            -- mutate 2

            if Random (Mutation_Random) < Mutation_Ratio then
			   Put_Line("Mutate :" & Image(Child2));
               Child2 := Mutate (Child2);
			   Put_Line(" Mutate result :" & Image(Child2));
            end if;

            Add (New_Pop, Child1, 2 * I - 1);
            Add (New_Pop, Child2, 2 * I);

         end;

      end loop;

      New_Pop.Pop := Sort_Gene_Array (New_Pop.Pop);
      return New_Pop;
   end New_Generation;

end Ga.Population;
