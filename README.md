Ada-GA
======

This project is a small library to compute genetic algorithm in Ada.

The aim is to use the Ada Generic System to provide the best performances (Mostly Static, no heap allocation).

Currently :
- binary chromosomes are provided, additional chromosome could be used in creating a new chromosome type
- Population Elitism (conserv a pourcentage of the best chromosomes)
- Mutations
- CrossOver

Random Generators are clearly separated on :
- Mutation
- CrossOver
- Chromosome

a test function show the use of the library for a scalar encoding of chromosome.

## Install - Compile - Test ##

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
    

