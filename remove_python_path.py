
__all__ = ['remove_path']

def remove_path():
    import sys
    sys.path.remove('/workspace/git/albumentations')
    sys.path.remove('/workspace/git/AdelaiDet')
    print(sys.path)

