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
   type Chromosome is private;
   with function Eval (C : Chromosome) return Float;
   with procedure Cross_Over
     (C1, C2       : in Chromosome;
      Cout1, Cout2 : out Chromosome);
   with function Mutate (C : Chromosome) return Chromosome;
   with function Random return Chromosome;

   Pop_Size : Positive := 50;
   Pop_Conservation : Float := 0.8; -- on garde les 80 des meilleurs individus
                                    --pour le cross over

   -- cross over rate, if the random usage is below the Crossover_Ratio, we
   -- make a crossover on the 2 chromosomes
   Crossover_Ratio : Float := 0.7;

   -- mutation ratio for mutate the chromosome
   Mutation_Ratio : Float := 0.05;

package Ga.Population is

   type Pop_Type is private;

   -- create a new random population
   function Create_Random_Pop return Pop_Type;

   -- compute a new generation for this population
   function New_Generation (P : Pop_Type) return Pop_Type;

   -- return the best chromosome for this population
   function Best_Chromosome (P : Pop_Type) return Chromosome;

   Empty_Population : exception;

private

   -- Chromosome with its associated value
   type Evaluated_Chromosome is record
      C : Chromosome;
      V : Float;
   end record;

   -- array of Evaluated_Chromosome
   type Evaluated_Chromosome_Array is
     array (Positive range <>) of Evaluated_Chromosome;

   -- Population type
   type Pop_Type is record
      Pop              : Evaluated_Chromosome_Array (1 .. Pop_Size);
      Chromosome_Count : Natural := 0;
   end record;

end Ga.Population;
