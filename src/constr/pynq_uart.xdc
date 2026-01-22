set_property PACKAGE_PIN A9   [get_ports {LED[0]             }];  # "A9.RADIO_LED0"
set_property PACKAGE_PIN B9   [get_ports {LED[1]             }];  # "B9.RADIO_LED1"

set_property PACKAGE_PIN F8   [get_ports {HD_GPIO_1              }];  # "F8.HD_GPIO_1"
set_property PACKAGE_PIN F7   [get_ports {HD_GPIO_2              }];  # "F7.HD_GPIO_2"

set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 26]];
