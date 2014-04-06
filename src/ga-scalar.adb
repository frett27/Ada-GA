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
with Ada.Text_IO;
use Ada.Text_IO;

package body GA.Scalar is


   function Eval (C : Binary_Gene)
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

   package Binary_Gene_Random is
      new Ada.Numerics.Discrete_Random(Binary_Gene_Range);

   Binary_Gene_Generator : Binary_Gene_Random.Generator;

   procedure Cross_Over (C1, C2       : in     Binary_Gene;
                         Cout1, Cout2 :    out Binary_Gene)
   is
      use Binary_Gene_Random;
      Decoupe : Binary_Gene_Range :=
       Random(Binary_Gene_Generator);
   begin
      
      -- Put_Line ("Decoupe :" & Binary_Gene_Range'Image(Decoupe));

      if Decoupe = Binary_Gene_Range'First or
        Decoupe = Binary_Gene_Range'Last then
         Cout1 := C2;
         Cout2 := C1;
      else

		 declare
			OUT1, OUT2 : Binary_Gene;
		 begin

			 OUT1(Binary_Gene_Range'First .. Decoupe)
			   := C1(Binary_Gene_Range'First .. Decoupe);
			 OUT1(Decoupe + 1 .. Binary_Gene_Range'Last)
			   := C2(Decoupe + 1 .. Binary_Gene_Range'Last);

			 OUT2(Binary_Gene_Range'First .. Decoupe)
			   := C2(Binary_Gene_Range'First .. Decoupe);
			 OUT2(Decoupe + 1 .. Binary_Gene_Range'Last)
			   := C1(Decoupe + 1 .. Binary_Gene_Range'Last);

			 Cout1 := OUT1;
			 Cout2 := OUT2;

		 end;
      end if;


   end;

   function Mutate (C : Binary_Gene)
                   return Binary_Gene
   is
      N : Binary_Gene_Range :=
        Binary_Gene_Random.Random(Binary_Gene_Generator);
      Cout : Binary_Gene := C;
   begin
      Cout(N) := not Cout(N);
      return Cout;
   end;

   type Boolean_Range is range 0..1;

   package Boolean_Random is
      new Ada.Numerics.Discrete_Random(Boolean_range);

   Boolean_Generator : Boolean_Random.Generator;

   function Random
     return Binary_Gene is
      use Boolean_Random;
      Cout : Binary_Gene := (others => False);
   begin
      for I in Binary_Gene'Range loop
         if Random(Boolean_Generator) = 1 then
            Cout(I) := True;
         end if;
      end loop;
      return Cout;
   end;


   function Image (C : Binary_Gene) return String is
      S : String(Integer(C'First)..Integer(C'Last));
   begin
	  for i in C'range loop
          if (C(i)) then
             S(Integer(i)) := '1';
          else
             S(Integer(i)) := '0';
          end if;
      end loop;
      return S;
   end;

end Ga.Scalar;
