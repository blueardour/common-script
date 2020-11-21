
__all__ = ['remove_path']

def remove_path():
    import sys
    remove_list = ['/workspace/git/albumentations', '/workspace/git/AdelaiDet']
    add_list = ['/workspace/git/onnx-tensorrt']
    for i in remove_list:
        if  i in sys.path:
            sys.path.remove(i)
    for i in add_list:
        if i not in sys.path:
            sys.path.insert(0, '/workspace/git/onnx-tensorrt')
    print("Info", sys.path)

