---
date: 2021-09-05 11:12
description: ESPHome custom component vs component (contribution) development
tags: 
tagColors: 
---
# Difference of development between custom component and full-fledged component for ESPHome

There are two approaches that can be used to develop a custom component for ESPHome:
1. A simplified version described in the ESPHome documentation ([Custom Sensor Compoent](https://esphome.io/components/sensor/custom.html) and [Generic Custom Component](https://esphome.io/custom/custom_component.html)) that doesn't provide as much reusability as the "full-fledged" component 
2. Native - "full-fledged" component that you can find e.g. [ESPHome Build-in Components](https://github.com/esphome/esphome/tree/dev/esphome/components) and its creation is described in the [Contribution Guide](https://esphome.io/guides/contributing.html)

For better communication to distinguish components, I will call the former _Simple_ and the latter  _Native_.

The _Simple_ component development is quite well described in the ESPHome documentation. In a nutshell, it just requires creating the `.h` + optionally `.cpp` file with the C++ (Arduino) component implementation and then the `yaml` file that registers the component so it can be used as any other ESPHome component. All that is clearly explained in the above documentation references.

In the case of the _Native_ component development, this gets more tricky. The contribution guide sheds a bit of light on how to start but without many details. The most tricky part is how to properly write the `__init__` and/or`sensor.py` which defines the component, validation, and C++ code generation (more details in the contribution guide). Most of the time it requires checking other component's implementations and based on that conclude what is actually needed. It's not that hard but requires a bit of Python knowledge. The C++ part is not that much different than the _Simple_ component implementation. If you already have _Simple_ implementation it can be copy/pasted, add `namespace esphome`, another inner for the component, and you are good to go.

If you would like to understand better the difference between the _Simple_ and _Native_ component implementation take a look at my [repository](https://github.com/nonameplum/esphome_devices). I implemented the same sensor using both approaches. You can find the _Simple_ component implementation in [custom_components/mq9](https://github.com/nonameplum/esphome_devices/tree/main/custom_components/mq9) and _Native_ in [components/mq](https://github.com/nonameplum/esphome_devices/tree/main/components/mq). Also, the example of how to use it is defined in [mq9_test.yaml](https://github.com/nonameplum/esphome_devices/blob/main/mq9_test.yaml)

The _Native_ component is loaded thanks to the `external_components` definition in [config_base.yaml](https://github.com/nonameplum/esphome_devices/blob/main/common/config_base.yaml).

To switch between the _Native_ and _Simple_ component usage uncomment the line that defines `mq9_base` in the [mq9_test.yaml](https://github.com/nonameplum/esphome_devices/blob/41d024326db55ef2ee7b357bd58dabdbc18f53c1/mq9_test.yaml#L18).