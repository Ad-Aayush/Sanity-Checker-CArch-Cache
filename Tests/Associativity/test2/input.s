.data
.dword 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
.text
lui x3, 0x10
ld x4, 0(x3)
ld x4, 16(x3)
ld x4, 32(x3)
ld x4, 48(x3)
ld x4, 64(x3)
ld x4, 80(x3)
ld x4, 96(x3)
ld x4, 112(x3)
ld x4, 0(x3)
ld x4, 16(x3)
ld x4, 32(x3)
ld x4, 48(x3)
ld x4, 64(x3)
ld x4, 128(x3)
ld x4, 0(x3)