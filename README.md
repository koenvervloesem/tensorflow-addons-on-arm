# TensorFlow Addons on ARM 

[![Continous Integration](https://github.com/koenvervloesem/tensorflow-addons-on-arm/workflows/Tests/badge.svg)](https://github.com/koenvervloesem/tensorflow-addons-on-arm/actions)
[![GitHub license](https://img.shields.io/github/license/koenvervloesem/tensorflow-addons-on-arm.svg)](https://github.com/koenvervloesem/tensorflow-addons-on-arm/blob/master/LICENSE)

[TensorFlow Addons](https://www.tensorflow.org/addons) is a repository of community contributions that implement new functionality not available in the open source machine learning platform [TensorFlow](https://www.tensorflow.org). Unfortunately, the TensorFlow Addons project doesn't provide a PyPI package for armhf.

However, with some patches and the right combination of build requirements TensorFlow Addons can be compiled from source on the Raspberry Pi. TensorFlow Addons on ARM is a script that streamlines this and builds TensorFlow Addons for the Raspberry Pi's ARMv7 processor architecture with a single command: `make tfa`.

## System requirements

* Raspberry Pi (tested on Raspberry Pi 4B with 2 GB RAM)
* 16 GB microSD card
* [Raspberry Pi OS](https://www.raspberrypi.org/downloads/raspberry-pi-os/) (previously called Raspbian) Buster (10), 32-bit

If you manage to make this work on another version of Raspbian, another Linux distribution, another model of the Raspberry Pi or even another ARM computer, please let me know so I can generalize the script.

## Compatibility

Currently TensorFlow Addons on ARM only builds TensorFlow Addons for the following combination:

| TensorFlow Addons | TensorFlow | Python | Architecture |
| ----------------- | ---------- | ------ | ------------ |
| 0.7.1             | 2.1.0      | 3.7    | armhf        |

If you manage to make another combination work, please contribute your patches so other people can benefit too.

## Build requirements 

First make sure to have all build requirements.

### Bazel

TensorFlow Addons uses [Bazel](https://bazel.build) as its build system. As Raspberry Pi OS (Raspbian) doesn't have a package for Bazel and the Bazel project doesn't provide a binary for armhf, you have to build Bazel yourself. You can use [Bazel on ARM](https://github.com/koenvervloesem/bazel-on-arm) for this. The installation then comes down to:

```shell
git clone https://github.com/koenvervloesem/bazel-on-arm.git
cd bazel-on-arm
sudo make requirements
make bazel
sudo make install
```

Note that this installs a whopping 1 GB of JDK files. The build itself takes roughly half an hour on a Raspberry Pi 4B.

### TensorFlow

I tested this project in combination with Q-engineering's Python wheel tensorflow-2.1.0-cp37-cp37m-linux_armv7l.whl in their repository [TensorFlow-Raspberry-Pi](https://github.com/Qengineering/TensorFlow-Raspberry-Pi). They have excellent installation instructions and they also explain how to build the wheel from source: [Install TensorFlow 2.1.0 on Raspberry Pi 4](https://qengineering.eu/install-tensorflow-2.1.0-on-raspberry-pi-4.html).

The installation comes down to:

```shell
sudo apt install gfortran
sudo apt install libhdf5-dev libc-ares-dev libeigen3-dev
sudo apt install libatlas-base-dev libopenblas-dev libblas-dev
sudo apt install liblapack-dev cython
pip3 install pybind11
pip3 install h5py
wget https://github.com/Qengineering/Tensorflow-Raspberry-Pi/raw/master/tensorflow-2.1.0-cp37-cp37m-linux_armv7l.whl
pip3 install tensorflow-2.1.0-cp37-cp37m-linux_armv7l.whl
```

If the installation went well, you should be able to import TensorFlow in a Python 3 shell:

```python
>>> import tensorflow as tf
>>> tf.__version__
'2.1.0'
```

You don't need to install the TensorFlow 2.1.0 C++ API (`libtensorflow.so` and `libtensorflow_framework.so`).

## Usage

If all build requirements are met, building TensorFlow Addons is as easy as:

```shell
make tfa
```

The build script downloads TensorFlow Addons 0.7.1, patches it, configures the Bazel build file `.bazelrc` and then builds TensorFlow Addons. After a while (it doesn't take that long) you should see a message like this:

```shell
Sat 4 Jul 17:30:02 BST 2020 : === Output wheel file is in: /home/pi/tensorflow-addons-on-arm/addons-0.7.1/artifacts
```

You can then install the Python wheel with:

```shell
pip3 install addons-0.7.1/artifacts/tensorflow_addons-0.7.1-cp37-cp37m-linux_armv7l.whl
```

If the installation was successful, you should be able to import TensorFlow Addons in a Python 3 shell:

```python
>>> import tensorflow_addons as tfa
>>> tfa.__version__
'0.7.1'
```

## Motivation 

I needed [TensorFlow Addons](https://www.tensorflow.org/addons) because I wanted to run [Rasa](https://rasa.com/) on my Raspberry Pi. To my big surpise I didn't find any ARM build of TensorFlow Addons, and it turned out to be a real challenge.

The current stable version of Rasa uses TensorFlow 2.1, TensorFlow Addons 0.7.1 and Python 3.7. That's why currently this is the only combination of versions this project targets. When Rasa moves on to TensorFlow 2.2, I'm planning to build the corresponding TensorFlow Addons 0.10.0 for ARM. If someone else has patches to make this happen, please contribute them so others can benefit.

## References

I had to search through a lot of references to make TensorFlow Addons build on ARM. These are some of the references that I used:

* Q-engineering's article [Install TensorFlow 2.1.0 on Raspberry Pi 4](https://qengineering.eu/install-tensorflow-2.1.0-on-raspberry-pi-4.html), and more specifically their suggestion to link the atomic library, was invaluable.
* I encountered a [missing symbol when opening `_parse_time_op.so`](https://github.com/tensorflow/addons/issues/663). Unfortunately this is already triggered when you import the TensorFlow Addons library. I couldn't find another solution than not importing `parse_time` on initialization of the library.

Q-engineering's TensorFlow build is not the only one for ARM. Others are:

* [PINTO0309/Tensorflow-bin](https://github.com/PINTO0309/Tensorflow-bin) has pre-built wheels for the Raspberry Pi and Jetson Nano.
* [lhelontra/tensorflow-on-arm](https://github.com/lhelontra/tensorflow-on-arm) has a build script and pre-built wheels for various TensorFlow versions for the Raspberry Pi, RK3399 and other ARM devices.
* [The official Python wheels](https://www.tensorflow.org/install/pip) for TensorFlow 2.2.0 are built for Python 3.5, which is for Raspbian Stretch (9).

## License

This project is provided by [Koen Vervloesem](mailto:koen@vervloesem.eu) as open source software with the MIT license. See the [LICENSE](LICENSE) file for more information.
