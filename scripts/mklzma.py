import lzma, struct, sys
src, dst = sys.argv[1], sys.argv[2]
data = open(src, 'rb').read()
c = lzma.LZMACompressor(format=lzma.FORMAT_ALONE,
    filters=[{"id": lzma.FILTER_LZMA1, "preset": 9, "lc": 1, "lp": 2, "pb": 2, "dict_size": 8 << 20}])
out = bytearray(c.compress(data) + c.flush())
out[5:13] = struct.pack('<Q', len(data))   # ghi kich thuoc that vao header nhu cong cu lzma cua OpenWrt
open(dst, 'wb').write(out)
