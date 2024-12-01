lui x3, 0x10
lui x2, 0x10
addi x2, x2, 512
ld x4, 0(x3)
ld x4, 32(x3)
ld x4, 64(x3)
sd x4, 32(x2)
sd x4, 64(x2)
sd x4, 0(x3)
ld x4, 32(x2)
ld x4, 32(x3)