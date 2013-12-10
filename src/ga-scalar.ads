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


-- implementation of a fixed length chromosome using binary scheme

generic

   type Binary_Gene_Range is range <>;

package Ga.Scalar is

   type Binary_Gene is
        array(Binary_Gene_Range) of Boolean;

   -- eval the value of the chromosome
   function Eval(C : Binary_Gene) return Float;

   -- cross_over two chromosome
   procedure Cross_Over (C1, C2       : in     Binary_Gene;
                         Cout1, Cout2 :    out Binary_Gene);

   -- mutate a chromosome
   function Mutate (C : Binary_Gene) return Binary_Gene;

   -- random generation of a chromosome
   function Random return Binary_Gene;

   function Image (C : Binary_Gene) return String;


end Ga.Scalar;
