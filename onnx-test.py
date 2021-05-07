
import sys
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

####
# pip install onnx=1.5.0 onnxruntime
# cd ~/workspace/git && git clone 
import sys, os
workspace='~/workspace/git/onnx-simplifier'
sys.path.insert(0, workspace)

import onnx
print(onnx.__version__)

import onnxsim
print(onnxsim.__version__)

onnx_path='output.onnx'
onnx_model = onnxsim.simplify(onnx_path)
onnx.save(onnx_model, onnx_path.replace('.onnx', '-update.onnx'))
###


class Test(nn.Module):
    def __init__(self):
        super().__init__()

    def forward(self, x):
        #return F.interpolate(x, size=(400, 600), mode='bilinear', align_corners=False) #no warning, all clear
        #return F.interpolate(x, size=(400, 600), mode='bilinear') #no warning, all clear
        return F.interpolate(x, size=(400, 600), mode='nearest') #no warning, all clear

model = Test()
x = torch.rand((1, 3, 200, 300))
torch.onnx.export(model, x, "/tmp/test-opset11.onnx", verbose=True, opset_version=11)
torch.onnx.export(model, x, "/tmp/test-opset09.onnx", verbose=True, opset_version=9)

model.eval()
with torch.no_grad():
    torch_out = model(x)

####  opset 11 ####
onnx_file="/tmp/test-opset11.onnx"
onnx_model = onnx.load(onnx_file)
onnx.checker.check_model(onnx_model)

# onnxruntime
try:
    ort_session = onnxruntime.InferenceSession(onnx_file)
    ort_input = {ort_session.get_inputs()[0].name: x.cpu().numpy()}
    ort_out = ort_session.run(None, ort_input)[0]
    np.testing.assert_allclose(torch_out.cpu().numpy(), ort_out, rtol=1e-03, atol=1e-05)
    print("done in onnxruntime op11")
except:
    print("Catch error in onnxruntime op11")

# caffe2
try:
    load_model = onnx.load(onnx_file)
    onnx_model = backend.prepare(load_model)
    outputs = onnx_model.run(x.data.numpy())
    caffe2 = outputs[0]
    np.testing.assert_allclose(torch_out.cpu().numpy(), caffe2, rtol=1e-03, atol=1e-05)
    print("done in caffe2 11")
except:
    print("Catch error in caffe2 op11")

####  opset 9 ####
onnx_file="/tmp/test-opset09.onnx"
onnx_model = onnx.load(onnx_file)
onnx.checker.check_model(onnx_model)

# onnxruntime
try:
    ort_session = onnxruntime.InferenceSession(onnx_file)
    ort_input = {ort_session.get_inputs()[0].name: x.cpu().numpy()}
    ort_out = ort_session.run(None, ort_input)[0]
    np.testing.assert_allclose(torch_out.cpu().numpy(), ort_out, rtol=1e-03, atol=1e-05)
    print("done in onnxruntime 09")
except:
    print("Catch error in onnxruntime 09")

# caffe2
try:
    load_model = onnx.load(onnx_file)
    onnx_model = backend.prepare(load_model)
    outputs = onnx_model.run(x.data.numpy())
    caffe2 = outputs[0]
    np.testing.assert_allclose(torch_out.cpu().numpy(), caffe2, rtol=1e-03, atol=1e-05)
    print("done in caffe2 09")
except:
    print("Catch error in caffe2 09")


