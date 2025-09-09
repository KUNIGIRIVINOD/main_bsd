<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The *8-bit Binary Symmetry Detector (BSD)* project is designed to check whether an 8-bit binary input is symmetric, meaning it reads the same from left to right and right to left (like a palindrome). The 8-bit input is represented as $x_7x_6x_5x_4x_3x_2x_1x_0$. For the input to be symmetric, the following conditions must hold true simultaneously: $x_7 = x_0$, $x_6 = x_1$, $x_5 = x_2$, and $x_4 = x_3$. The circuit implements this by using *XNOR gates* to compare each pair of bits, since an XNOR outputs 1 only when the inputs are equal. The results of the four XNOR comparisons are then fed into an *AND gate*, ensuring that the final output S becomes 1 only when all pairs match, indicating a symmetric input; otherwise, S is 0. The Verilog testbench applies all possible 256 input combinations, computes the expected result in software, and compares it against the hardware output to verify correctness. During simulation, signals such as the input vector, the circuit’s output, the expected result, and any mismatch count are observed on GTKWave. For example, an input like 11111111 or 10000001 produces an output S = 1 (symmetric), while an input like 11001010 produces S = 0 (not symmetric). This makes the BSD project a simple yet effective demonstration of digital design principles, combining logic gate design with HDL simulation and verification.

## How to test

You can test your *8-bit Binary Symmetry Detector (BSD)* in two main ways:

---

### *1. Simulation (most common)*

* Write a *Verilog testbench* (you already have one).
* In the testbench, apply input values (either all 256 possible inputs or just a few selected ones).
* For each input, the testbench calculates the *expected output* using simple conditions:

  verilog
  expected = (x[7]==x[0]) && (x[6]==x[1]) && (x[5]==x[2]) && (x[4]==x[3]);
  
* Compare expected with the actual circuit output S.
* Print a message if they don’t match.
* At the end, display if all tests passed.
* Use *GTKWave* to observe the waveforms (input x, circuit output S, expected output).

If S always equals expected, then your design is correct.

---

### *2. Manual Testing (quick check)*

If you don’t want to run all 256 inputs, you can just test a few key cases:

* 00000000 → symmetric → S = 1
* 11111111 → symmetric → S = 1
* 10000001 → symmetric → S = 1
* 10100101 → symmetric → S = 1
* 11001010 → not symmetric → S = 0
* 00011000 → not symmetric → S = 0

---

In short: the easiest way is to *run the testbench* and confirm that the errors signal remains 0 after simulation.

Do you want me to *write a compact Verilog testbench* that automatically shows Pass/Fail at the end (instead of checking manually in GTKWave)?

## External hardware

:LED
