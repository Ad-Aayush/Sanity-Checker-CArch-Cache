lui x3, 0x10
lui x2, 0x10
lui x4, 0x10
lui x5, 0x10
lui x6, 0x10
addi x3, x3, 128
addi x4, x4, 256
addi x5, x5, 512
addi x6, x6, 1024
addi x12, x0, 16
ld x10, 0(x2)
sd x10, 0(x3)
ld x10, 0(x4)
ld x10, 0(x5)
sd x10, 0(x2)
ld x10, 0(x6)
ld x10, 0(x3)
ld x10, 0(x2)
sd x12, 0(x4)