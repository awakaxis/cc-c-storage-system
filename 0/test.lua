gpu = peripheral.wrap('right')
gpu.refreshSize()
gpu.setSize(64)
size = table.pack(gpu.getSize())
handle = io.open('a.png', 'r')
print(handle.read("a"))
image = gpu.decodeImage(1)
gpu.sync()
