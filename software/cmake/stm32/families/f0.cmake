set(STM32_F0_TYPES
	# STM32F0x0 Value Line
	F030x6 F030x8 F030xC F070x6 F070xB
	# STM32F0x1 Access Line
	F031x6 F051x8 F071xB F091xC
	# STM32F0x2 USB Line
	F042x6 F072xB
	# STM32F0x8 Low-Voltage Line
	F048xx F058xx F078xx F038xx F098xx
)

_stm32_create_family_targets(
	FAMILY F0
	TYPES ${STM32_F0_TYPES}
)

target_compile_options(STM32::F0 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0>
)

target_link_options(STM32::F0 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0>
)
