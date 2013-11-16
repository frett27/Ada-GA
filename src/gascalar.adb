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

with Ada.Numerics.Discrete_Random;

package body Gascalar is


   function Eval (C : Chromosome)
                 return Float is
      N : Natural := 0;
      P : Positive := 1;
   begin
      for I in C'Range loop
         if C(I) then
            N := N + P;
         end if;
         P:= P * 2;
      end loop;
      return Float(N);
   end;

   package Chromosome_Random is
      new Ada.Numerics.Discrete_Random(Chromosome_Range);

   Chromosome_Generator : Chromosome_Random.Generator;

   procedure Cross_Over (C1, C2       : in     Chromosome;
                         Cout1, Cout2 :    out Chromosome)
   is
      use Chromosome_Random;
      Decoupe : Chromosome_Range :=
       Random(Chromosome_Generator);
   begin

      if Decoupe = Chromosome_Range'First or
        Decoupe = Chromosome_Range'Last then
         Cout1 := C2;
         Cout2 := C1;
      else

         Cout1(Chromosome_Range'First .. Decoupe)
           := C1(Chromosome_Range'First .. Decoupe);
         Cout1(Decoupe + 1 .. Chromosome_Range'Last)
           := C2(Decoupe + 1 .. Chromosome_Range'Last);

         Cout2(Chromosome_Range'First .. Decoupe)
           := C2(Chromosome_Range'First .. Decoupe);
         Cout2(Decoupe + 1 .. Chromosome_Range'Last)
           := C1(Decoupe + 1 .. Chromosome_Range'Last);

      end if;


   end;

   function Mutate (C : Chromosome)
                   return Chromosome
   is
      N : Chromosome_Range :=
        Chromosome_Random.Random(Chromosome_Generator);
      Cout : Chromosome := C;
   begin
      Cout(N) := not Cout(N);
      return Cout;
   end;

   type Boolean_Range is range 0..1;

   package Boolean_Random is
      new Ada.Numerics.Discrete_Random(Boolean_range);

   Boolean_Generator : Boolean_Random.Generator;

   function Random
     return Chromosome is
      use Boolean_Random;
      Cout : Chromosome := (others => False);
   begin
      for I in Chromosome'Range loop
         if Random(Boolean_Generator) = 1 then
            Cout(I) := True;
         end if;
      end loop;
      return Cout;
   end;

end Gascalar;
