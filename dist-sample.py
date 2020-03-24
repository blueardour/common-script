
import os
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from torch.utils.data.distributed import DistributedSampler


torch.distributed.init_process_group(backend="nccl")

input_size = 5
output_size = 2
batch_size = 2
data_size = 16

local_rank = torch.distributed.get_rank()
torch.cuda.set_device(local_rank)
device = torch.device("cuda", local_rank)

class RandomDataset(Dataset):
    def __init__(self, size, length, local_rank):
        self.len = length
        self.data = torch.stack([torch.ones(input_size), torch.ones(5)*2,
                                 torch.ones(input_size)*3,torch.ones(5)*4,
                                 torch.ones(input_size)*5,torch.ones(5)*6,
                                 torch.ones(input_size)*7,torch.ones(5)*8,
                                 torch.ones(input_size)*9, torch.ones(5)*10,
                                 torch.ones(input_size)*11,torch.ones(5)*12,
                                 torch.ones(input_size)*13,torch.ones(5)*14,
                                 torch.ones(input_size)*15,torch.ones(5)*16]).to('cuda')

        self.local_rank = local_rank
    def __getitem__(self, index):

        return self.data[index]

    def __len__(self):
        return self.len

def worker_init_reset_seed(worker_id):
    print(worker_id, os.getpid())
    print(torch.utils.data.get_worker_info())
    seed_all_rng(np.random.randint(2 ** 31) + worker_id)

dataset = RandomDataset(input_size, data_size, local_rank)
sampler = DistributedSampler(dataset)
rand_loader = DataLoader(dataset=dataset,
                         batch_size=batch_size,
                         num_workers=0,
                         sampler=sampler,
                         worker_init_fn=worker_init_reset_seed,
                        )

e = 0
while e < 2:
    t = 0
    # sampler.set_epoch(e)
    for data in rand_loader:
        print(data)
    e+=1

