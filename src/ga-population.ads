------------------------------------------------------------------------------
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

-- Template for defining a generic population
generic
   type Gene is private;
   with function Eval (C : Gene) return Float;
   with procedure Cross_Over (C1, C2 : in Gene; Cout1, Cout2 : out Gene);
   with function Mutate (C : Gene) return Gene;
   with function Random return Gene;
   with function Image (C : Gene) return String;

   Pop_Size : Positive := 50;
   Pop_Conservation : Float := 1.0; -- keep only a fraction of the population for cross over
		-- that is also called elitism

   -- cross over rate, if the random usage is below the Crossover_Ratio, we
   -- make a crossover on the 2 chromosomes
   Crossover_Ratio : Float := 0.7;

   -- mutation ratio for mutate the chromosome
   Mutation_Ratio : Float := 0.03;

package Ga.Population is

   type Pop_Type is private;

   -- create a new random population
   function Create_Random_Pop return Pop_Type;

   -- compute a new generation for this population
   function New_Generation (P : Pop_Type) return Pop_Type;

   -- return the best chromosome for this population
   function Best_Gene (P : Pop_Type) return Gene;

   -- display the pop for debug purpose
   procedure Dump (Popu : in Pop_Type);

   Empty_Population : exception;

private

   -- Gene with its associated value
   type Evaluated_Gene is record
      C : Gene;
      V : Float;
   end record;

   subtype Pop_Range is Positive range 1 .. Pop_Size;

   -- array of Evaluated_Gene
   type Evaluated_Gene_Array is array (Pop_Range range <>) of Evaluated_Gene;

   -- Population type
   type Pop_Type is record
      Pop     : Evaluated_Gene_Array (Pop_Range);
      Pop_Sum : Float;
   end record;

end Ga.Population;
