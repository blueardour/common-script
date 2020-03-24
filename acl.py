
from __future__ import print_function

def printf(table, additions):
  assert len(table) == len(additions[0])
  for row, i in enumerate(table):
    #print(i)
    if row == 0:
      print("index | ", end='')
    else:
      print("%d | " % row, end='')
    for col, j in enumerate(i):
      if col in [5,6,7]:
        continue
      if isinstance(j, list):
        for metric, k in enumerate(j):
          if metric in [0,1,2]:
            continue
          print("%s | " % k, end='')
      else:
        print("%s | " % j, end='')
    for extra in additions:
      if isinstance(extra[row], int):
        print("%.1f | " % (float(i[9][4]) / extra[row]), end='')
        #print("%.1f | " % (extra[row]), end='')
      else:       
        print("%s | " % extra[row], end='')

    print("")


def main():
  table = []
  filenames = ['acl-gpu415.log', 'acl-gpu767.log']
  w,h,cin,cout,pad,stride,dilation,kernel = 'width','height','cin','cout','pad','stride','dilation','kernel'
  time = ['CPU Direct', 'CPU GEMM', 'CPU Winograd', 'GPU Direct', 'GPU GEMM', 'GPU Winograd']
  table.append(['Freq',w,h,cin,cout,pad,stride,dilation,kernel,time]) 
  flag = False
  for filename in filenames:
    w,h,cin,cout,pad,stride,dilation,kernel = '-','-','-','-','-','-','-','-'
    time = []
    with open(filename) as f:
      for line in f:
        #print line
        if 'width and height' in line:
          info = line.split('width and height:')[1]
          info = [ i.strip() for i in info.split(',')]
          w, h = info[0], info[1]
        if 'cin and cout' in line:
          info = line.split('cin and cout:')[1]
          info = [ i.strip() for i in info.split(',')]
          cin, cout = info[0], info[1]
        if 'pad, stride, dilation:' in line:
          info = line.split('pad, stride, dilation:')[1]
          info = [ i.strip() for i in info.split(',')]
          pad,stride,dilation = info[0], info[1], info[2]
        if 'kernel:' in line:
          info = line.split('kernel:')[1]
          info = [ i.strip() for i in info.split(',')]
          kernel = info[0]
        if 'time cost for execution' in line:
          info = line.split(' ')[-2]
          time.append(info)
        if 'Enter test_cpu' in line:
          flag = True
        if '==> layer info' in line and flag:
          info = filename.split('.')[0].split('-gpu')[1]
          table.append([info,w,h,cin,cout,pad,stride,dilation,kernel,time]) 
          w,h,cin,cout,pad,stride,dilation,kernel = '-','-','-','-','-','-','-','-'
          time = []
          flag = False
      if flag:
          info = filename.split('.')[0].split('-gpu')[1]
          table.append([info,w,h,cin,cout,pad,stride,dilation,kernel,time]) 
          flag = False

  assert len(table) == 21
  filenames = ['../ai-benchmark/log/arm-gpu415.log', '../ai-benchmark/log/arm-gpu767.log']
  lists = []
  for filename in filenames:
    with open(filename) as f:
      for line in f:
        #print line
        if 'best performance for layer' in line:
          info = line.split(' ')[-2]
          lists.append(int(info))
  assert len(lists) == 80
  #print(lists)
  col1 = []
  col2 = []
  col1.append('Speedup Binary')
  col2.append('Speedup Ternary')
  for i in range(10):
    col1.append(lists[i] + lists[i+10])
    col2.append(lists[i+20] + lists[i+30])
  for i in range(10):
    col1.append(lists[i+40] + lists[i+50])
    col2.append(lists[i+60] + lists[i+70])

  #print(col1)
  colums = [col1, col2]
  printf(table, colums)

if __name__ == "__main__":
  main()
