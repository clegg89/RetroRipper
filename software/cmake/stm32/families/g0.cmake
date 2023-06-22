set(STM32_G0_TYPES 
	# STM32G0x0 Value Line
	G030xx G050xx G070xx G0B0xx
	# STM32G0x1 Access Line
	G031xx G041xx G051xx G061xx G071xx G081xx G0B1xx G0C1xx
)

_stm32_create_family_targets(
	FAMILY G0
	TYPES ${STM32_G0_TYPES}
)

target_compile_options(STM32::G0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
target_link_options(STM32::G0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
