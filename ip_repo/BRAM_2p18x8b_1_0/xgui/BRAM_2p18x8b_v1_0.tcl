proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set_property tooltip {BRAM with 18-bit address and 8-bit data} [ipgui::add_param $IPINST -name "Component_Name"]
}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
  return true
}

proc update_PARAM_VALUE.BIT_WIDTH { PARAM_VALUE.BIT_WIDTH } {
  return true
}