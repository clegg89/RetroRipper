set(STM32_L4_TYPES 
	# STM32L4
	## STM32L4x1 Access Line
	L431xx 	L451xx 	L471xx
	## STM32L4x2 USB
	L412xx 	L422xx 	L432xx 	L442xx 	L452xx 	L462xx
	## STM32L4x3 USB & LCD
	L433xx 	L443xx
	## STM32L4x5 USB OTG
	L475xx 	L485xx
	## STM32L4x6 USB OTG & LCD
	L476xx 	L486xx 	L496xx 	L4A6xx
	# STM32L4+
	## STM32L4R5/STM32L4S5 USB OTG
	L4R5xx
	### With AES
	L4S5xx
	## STM32L4R7/STM32L4S7 USB OTG & TFT Interface
	L4R7xx
	### With AES
	L4S7xx
	## STM32L4R9/STM32L4S9 USB OTG & MIPI-DSI
	L4R9xx
	### With AES
	L4S9xx
	## STM32L4P5/STM32L4Q5 USB OTG
	L4P5xx
	### With AES
	L4Q5xx
)

stm32_create_family_targets(
	FAMILY L4
	TYEPS ${STM32_L4_TYPES}
)

target_compile_options(STM32::L4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::L4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
