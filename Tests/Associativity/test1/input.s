.data
.dword 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
.text
lui x3, 0x10
lui x5, 0x20
lui x6, 0x30
lui x7, 0x40
lui x8, 0x4A
ld x4, 0(x3)
ld x4, 16(x3)
ld x4, 0(x5)
ld x4, 16(x5)
ld x4, 0(x6)
ld x4, 16(x6)
ld x4, 0(x7)
ld x4, 16(x7)
ld x4, 0(x3)
ld x4, 16(x3)
ld x4, 0(x5)
ld x4, 16(x5)
ld x4, 0(x6)
ld x4, 16(x6)
ld x4, 0(x7)
ld x4, 16(x7)
ld x4, 0(x3)
ld x4, 0(x8)
ld x4, 16(x8)
ld x4, 0(x5)
ld x4, 16(x3)