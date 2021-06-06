

import torch

class F1(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x):
        y = x + 2
        print("In forward F1, ctx {}".format(ctx))
        return y

    @staticmethod
    def backward(ctx, grad_output):
        print("In backward F1, ctx {}".format(ctx))
        return grad_output

class F2(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x):
        y = F1.apply(x)
        print("In forward F2, ctx {}".format(ctx))
        y = F1.forward(ctx, x)
        return y

    @staticmethod
    def backward(ctx, grad_output):
        print("In backward F2, ctx {}".format(ctx))
        grad_output = F1.backward(ctx, grad_output)
        return grad_output


if __name__ == "__main__":
    x = torch.rand(3, 4)
    x.requires_grad = True
    y = F2.apply(x)
    z = y.sum()
    z.backward()

