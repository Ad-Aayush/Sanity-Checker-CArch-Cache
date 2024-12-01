lui x3, 0x10
lui x2, 0x10
lui x4, 0x10
lui x5, 0x10
lui x6, 0x10
addi x12, x0, 16
addi x3, x3, 128
addi x4, x4, 256
addi x5, x5, 512
addi x6, x6, 1024
ld x10, 16(x2)
sd x10, 16(x3)
ld x10, 8(x4)
sd x10, 0(x5)
sd x10, 16(x4)
ld x10, 0(x3)
sd x10, 8(x2)
sd x12, 8(x6)