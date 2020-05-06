
mapping='/workspace/git/popcount-net/weights/det-resnet101/mt-1.txt'
with open(mapping) as f:
    lines = f.readlines()
    f.close()

count=0
lists = []
buffer1 = []
buffer2 = []
for i in lines:
    if 'norm.weight' in i and 'res' in i and 'conv' in i:
        lists.append(i)
    elif 'conv' in i and 'weight' in i and 'res' in i:
        count = count + 1
        buffer1.append(i)
        if count == 3:
            lists += buffer1
            count = 0
            buffer1 = []
    elif 'shortcut.norm' in i:
        buffer2.append(i)
    elif 'shortcut.weight' in i:
        lists.append(i)
        lists += buffer2
        buffer2 = []
    else:
        lists.append(i)

for i in lists:
    i = i.strip(' ').strip('\n')
    if len(i) > 1:
        print(i)




        

