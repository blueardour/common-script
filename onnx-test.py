
import onnx
import onnxruntime
import caffe2.python.onnx.backend as backend

import torch.nn as nn
import torch
import torch.nn.functional as F
from torchvision import models
import numpy as np


#image_size = 224
#dummpy_input = torch.randn(1, 3, image_size, image_size)
#resnet50 = models.resnet50(pretrained=True)
#torch.onnx.export(resnet50, dummpy_input, "resnet50.onnx", verbose=True)
#onnx_model = onnx.load("resnet50.onnx")
#onnx.checker.check_model(onnx_model)    
#print("ok")


class Test(nn.Module):
    def __init__(self):
        super().__init__()

    def forward(self, x):
        return F.interpolate(x, size=(400, 600), mode='bilinear', align_corners=False) #no warning, all clear

model = Test()
x = torch.rand((1, 3, 200, 300))
torch.onnx.export(model, x, "test.onnx", verbose=True, opset_version=11)

model.eval()
with torch.no_grad():
    torch_out = model(x)

onnx_model = onnx.load("test.onnx")
onnx.checker.check_model(onnx_model)    

#ort_session = onnxruntime.InferenceSession("test.onnx")
#ort_input = {ort_session.get_inputs()[0].name: x.cpu().numpy()}
#ort_out = ort_session.run(None, ort_input)[0]
#np.testing.assert_allclose(torch_out.cpu().numpy(), ort_out, rtol=1e-03, atol=1e-05)


load_model = onnx.load("test.onnx")
print('prepare')
onnx_model = backend.prepare(load_model)
print('run')
#outputs = onnx_model.run({load_model.graph.input[0].name: x.data.numpy()})
outputs = onnx_model.run(x.data.numpy())
caffe2 = outputs[0]
try:
    print('compare')
    np.testing.assert_allclose(torch_out.cpu().numpy(), caffe2, rtol=1e-03, atol=1e-05)
except AssertionError as e:
    print(e)



