set(STM32_L0_TYPES 
	# STM32L0x0 Value Line
	L010x4 L010x6 L010x8 L010xB
	# STM32L0x1 Access Line
	L011xx L021xx L031xx L041xx L051xx L061xx L071xx L081xx
	# STM32L0x2 USB
	L052xx L062xx L072xx L082xx
	# STM32L0x3 USB & LCD
	L053xx L063xx L073xx L083xx
)

stm32_create_family_targets(
	FAMILY L0
	TYPES ${STM32_L0_TYPES}
)

target_compile_options(STM32::L0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
target_link_options(STM32::L0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
