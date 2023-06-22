set(STM32_F4_TYPES 
	# Advanced lines
	## STM32F427/STM32F437
	F427xx F437xx
	## STM32F429/STM32F439
	F429xx F439xx
	## STM32F469/STM32479
	F469xx F479xx
	# Foundation Lines
	## STM32F405/STM32F415
	F405xx F415xx
	## STM32F407/STM32F417
	F407xx F417xx
	## STM32F446
	F446xx
	# Access Lines
	## STM32F401
	F401xC F401xE
	## STM32F410
	F410Cx F410Rx F410Tx
	## STM32F411
	F411xE
	## STM32F412
	F412Cx F412Rx F412Vx F412Zx
	## STM32F413/STM32F423
	F413xx F423xx
)

_stm32_create_family_targets(
	FAMILY F4
	TYPES ${STM32_F4_TYPES})

target_compile_options(STM32::F4 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F4 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
