
import numpy as np
import torch
import matplotlib.pyplot as plt
import seaborn as sns
import os

font = {'family' : 'Times New Roman',
        'size'   : 20}

plt.rc('font', **font)


prefix='../AdelaiDet/log/probe-'
lists = [
        'proposal_generator.fcos_head.cls_tower.1.',
        'proposal_generator.fcos_head.cls_tower.4.',
        'proposal_generator.fcos_head.cls_tower.7.',
        'proposal_generator.fcos_head.cls_tower.10.',
        'proposal_generator.fcos_head.bbox_tower.1.',
        'proposal_generator.fcos_head.bbox_tower.4.',
        'proposal_generator.fcos_head.bbox_tower.7.',
        'proposal_generator.fcos_head.bbox_tower.10.',
        ]
for key in lists:
    plt.grid(True)
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
    for i in range(5):
        key_name = '{}{}{}-input.pth'.format(prefix, key, i)
        val = torch.load(key_name, map_location='cpu').to('cpu').numpy()
        sns.distplot(val.reshape(-1), kde=False, bins=100, label='level-{}'.format(i + 3))

    #plt.legend(loc='upper left')
    plt.legend(loc='best')
    plt.xlabel("magnitudes")
    plt.ylabel("num")
    plt.tight_layout()
    plt.savefig("{}{}hist.pdf".format(prefix, key))
    plt.close()

