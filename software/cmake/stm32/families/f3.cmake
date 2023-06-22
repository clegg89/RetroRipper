set(STM32_F3_TYPES 
	# STM32F301 Access
	F301x8
	# STM32F302 USB & CAN
	F302x8 F302xC F302xE
	# STM32F303 Performance
	F303x8 F303xC F303xE
	# STM32F3x4 Digital Power
	F334x8
	# STM32F373 Precision Measurement
	F373xC
	# STM32F3x8 1.8V +/- 8%
	F318xx F328xx F358xx F378xx F398xx
)

stm32_create_family_targets(
	FAMILY f3
	TYPES ${STM32_F3_TYPES}
)

target_compile_options(STM32::F3 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F3 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
