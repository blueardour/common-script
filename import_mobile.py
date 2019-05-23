
from torch._C import _add_docstr
import torch
import torch.nn as nn
import torch.nn.functional as F
import argparse

origin_add_docstr = _add_docstr

def get_parameter():
    parser = argparse.ArgumentParser("Pytorch Training")
    parser.add_argument('--model', '-m', default='resnet18', type=str)
    parser.add_argument('-t', '--test', action='store_true', default=False)
    parser.add_argument('--base', default=1, type=int)
    args = parser.parse_args()
    return args


def custom_docstr(method, docstr, origin=origin_add_docstr):
  if method == torch.conv2d:
    print('add conv2d')
  else:
    print('unknow layer', method, type(method))
  return origin(method, docstr)

def custom_F_conv2d(input, weight, bias=None, stride=1, padding=0, dilation=1, groups=1, padding_mode='zeros'):
    print('F conv2d')

def import_mobile(model, inputs):
  return None


class demo(nn.Module):
    def __init__(self):
        super(demo, self).__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(3, 64, 3, 1, 1, bias=False),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True)
            )

        self.pooling = nn.AvgPool2d(224)
        self.classifier = nn.Sequential (
            nn.Dropout(0.5),
            nn.Linear(64, 10)
            )

    def forward(self, x):
        x = self.conv(x)
        x = self.pooling(x)
        x = x.view(1, -1)
        x = self.classifier(x)
        return x

def main():
  args = get_parameter()
  torch.manual_seed(1)

  if args.test:
    _add_docstr = custom_docstr
    F.conv2d = custom_F_conv2d


  model = demo()
  inputs = torch.rand(1, 3, 224, 224)
  with torch.no_grad():
    output = model(inputs)
    print(output.shape)

if __name__ == '__main__':
    main()

