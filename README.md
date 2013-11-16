Ada-GA
======

This project is a small library to compute genetic algorithm in Ada. It currently support only scalar chromosomes.

a test function show the use of the library for a scalar encoding of chromosome.

## Install - Compile ##

This project should compile on every Ada 2005 compliant compiler.We currently use GNAT 2005.

to compile the project, go in the project directory and launch gprbuild command line.

> gprbuild

    C:\Projets\Ada\Projets\Ada-GA>gprbuild
    using project file ga.gpr
    gcc -c -g -gnat05 -O3 test.adb
    gcc -c -g -gnat05 -O3 ga.adb
    gcc -c -g -gnat05 -O3 gascalar.adb
    gprbind test.bexch
    gnatbind test.ali
    gcc -c b__test.adb
    gcc test.o -o test.exe
    

