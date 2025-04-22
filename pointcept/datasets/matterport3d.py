"""
Matterport3D Dataset

Author: Xiaoyang Wu (xiaoyang.wu.cs@gmail.com)
Please cite our work if the code is helpful to you.
"""

import os
import glob
import numpy as np
import torch
from collections.abc import Sequence

from .builder import DATASETS
from .defaults import DefaultDataset

from pointcept.utils.cache import shared_dict


@DATASETS.register_module()
class Matterport3DDataset(DefaultDataset):
    VALID_ASSETS = None

    def get_data_list(self):
        if isinstance(self.split, str):
            data_list = glob.glob(
                os.path.join(self.data_root, self.split, "*.pth")
            )
        elif isinstance(self.split, Sequence):
            data_list = []
            for split in self.split:
                data_list += glob.glob(
                    os.path.join(self.data_root, split, "*.pth")
                )
        else:
            raise NotImplementedError
        return data_list

    def get_data(self, idx):
        data_path = self.data_list[idx % len(self.data_list)]
        name = self.get_data_name(idx)
        split = self.get_split_name(idx)
        if self.cache:
            cache_name = f"pointcept-{name}"
            return shared_dict(cache_name)

        # Load data from .pth file
        coord, color, _ = torch.load(data_path)
        
        # Convert color to [0, 255] range
        color = np.clip((color + 1.0) * 127.5, 0, 255).astype(np.uint8)
        
        data_dict = {
            "coord": coord.astype(np.float32),
            "color": color.astype(np.float32),
            "name": name,
            "split": split
        }

        return data_dict