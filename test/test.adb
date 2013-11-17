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
with Ga.scalar;

with Ada.Text_Io;
use Ada.Text_Io;

procedure Test is


   subtype Chromosome_Length is Positive range 1..30;

   -- package for creating a bunch of scalar operators for GA chromosomes
   package CS is new Ga.Scalar(Binary_Chromosome_Range 
								=> Chromosome_Length);

   -- score function that evaluate the adaptative value of the chromosome
   -- this is the (Max - X)**2 function
   function Eval_X2(C : CS.Binary_Chromosome) return Float is
   begin
      return (Float(2 ** 30 - 1) - Cs.Eval(C)) ** 2;
   end;


   use Cs;

   -- instanciate the GA package for GA computation
   -- we mainly use the Gascalar operations, except for Eval
   package P is new Ga.Population(Chromosome=>Binary_Chromosome,
                       Eval => Eval_x2 ,
                       Cross_Over => Cross_Over,
                       Mutate => Mutate,
                       Random => Random,
                       Pop_Size => 500);
   -- current population
   Pop : P.Pop_Type := P.Create_Random_Pop;

begin

   Put_Line (" generation initiale ");
   Put_Line (CS.Image(P.Best_Chromosome(Pop)));

   Put_Line (" 5000 new generations ");
   for I in 1..5000 loop
      Pop := P.New_Generation(Pop);
   end loop;

   Put_Line(CS.Image(P.Best_Chromosome(Pop)));
   Put_Line( " Value of the best chromosome :" & Float'Image(Eval_x2(P.Best_Chromosome(Pop))));


end;
