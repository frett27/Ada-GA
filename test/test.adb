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

with Ga.Population;
with Ga.Scalar;

with Ada.Text_IO; use Ada.Text_IO;

with Ada.Numerics.Generic_Elementary_Functions;

procedure Test is

   subtype Gene_Length is Positive range 1 .. 30;

   -- package for creating a bunch of scalar operators for GA chromosomes
   package CS is new Ga.Scalar (Binary_Gene_Range => Gene_Length);

   package M is new Ada.Numerics.Generic_Elementary_Functions (Float);
   -- score function that evaluate the adaptative value of the chromosome
   -- this is the (Max - X)**2 function
   function Eval_X2 (C : CS.Binary_Gene) return Float is
      use M;
   begin
      return (Float (2 ** Gene_Length'Last) - CS.Eval (C)) ** 2;
   end Eval_X2;

   use CS;

   -- instanciate the GA package for GA computation
   -- we mainly use the Gascalar operations, except for Eval
   package P is new Ga.Population (
      Gene       => CS.Binary_Gene,
      Eval       => Eval_X2,
      Cross_Over => CS.Cross_Over,
      Mutate     => CS.Mutate,
      Random     => CS.Random,
      Image      => CS.Image,
      Pop_Size   => 200);

   procedure Test_Population is
      -- current population
      Pop : P.Pop_Type := P.Create_Random_Pop;
   begin

      Put_Line (" best chromosome of the initial generation :");
      Put_Line (CS.Image (P.Best_Gene (Pop)));
      Put_Line
        ("chromosome : " & Float'Image (Eval_X2 (P.Best_Gene (Pop))));
      Put_Line ("");

      for I in 1 .. 5000 loop
         Pop := P.New_Generation (Pop);
         Put_Line
           (" Pop :" &
            Natural'Image (I) &
            " best :" &
            CS.Image (P.Best_Gene (Pop)) &
            " - " &
            Float'Image (Eval_X2 (P.Best_Gene (Pop))));
         P.Dump (Pop);
      end loop;

      Put_Line
        (" Value of the best chromosome :" &
         Float'Image (Eval_X2 (P.Best_Gene (Pop))));
      Put_Line (CS.Image (P.Best_Gene (Pop)));

   end Test_Population;

   procedure Test_Cross_Over is
      G1, G2 : CS.Binary_Gene := CS.Random;
   begin
      Put_Line ("unit test");
      Put_Line (" C1 :" & CS.Image (G1));
      Put_Line (" C2 :" & CS.Image (G2));
      Put_Line ("Cross over :");
      CS.Cross_Over (G1, G2, G1, G2);

      Put_Line (" C1 :" & CS.Image (G1));
      Put_Line (" C2 :" & CS.Image (G2));
   end Test_Cross_Over;

begin
   Test_Population;
end Test;
