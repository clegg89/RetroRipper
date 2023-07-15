set(STM32_H7_SUBFAMILIES
	# All H7's have an M7
	M7
	# Dual-core variants also have an M4
	M4
)

set(STM32_H7_SUBFAMILY_PREFIX "CORE_")

# Note: The xxQ types below are not listed in the getting
# started page, but are in the CMSIS device header files
set(STM32_H7_M7_TYPES
	# Value Lines
	## STM32H730
	H730xx H730xxQ
	## STM32H750
	H750xx
	## STM32H7B0
	H7B0xx H7B0xxQ
	# Single-Core Lines
	## STM32H723/STM32H733
	H723xx H733xx
	## STM32H725/STM32H735
	H725xx H735xx
	## STM32H742
	H742xx
	## STM32H743/STM32H753
	H743xx H753xx
	## STM32H7A3/STM32H7B3
	H7A3xx H7A3xxQ H7B3xx H7B3xxQ
	# Dual-Core Lines
	## STM32H745/STM32H755
	H745xx H755xx
	## STM32H747/STM32H757
	H747xx H757xx
)

set(STM32_H7_M4_TYPES
	# Dual-core lines
	# STM32H745/STM32H755
	H745xx H755xx
	# STM32H747/STM32H757
	H747xx H757xx
)

set(STM32_H7_TYPES ${STM32_H7_M7_TYPES} ${STM32_H7_M4_TYPES})
list(REMOVE_DUPLICATES STM32_H7_TYPES)

set(STM32_H730xx_DEVICES "H730..")
set(STM32_H730xxQ_DEVICES "H730..Q")
set(STM32_H750xx_DEVICES "H750..")
set(STM32_H7B0xx_DEVICES "H7B0..")
set(STM32_H7B0xxQ_DEVICES "H7B0..Q")
set(STM32_H723xx_DEVICES "H723..")
set(STM32_H733xx_DEVICES "H733..")
set(STM32_H725xx_DEVICES "H725..")
set(STM32_H735xx_DEVICES "H735..")
set(STM32_H742xx_DEVICES "H742..")
set(STM32_H743xx_DEVICES "H743..")
set(STM32_H753xx_DEVICES "H753..")
set(STM32_H7A3xx_DEVICES "H7A3..")
set(STM32_H7A3xxQ_DEVICES "H7A3..Q")
set(STM32_H7B3xx_DEVICES "H7B3..")
set(STM32_H7B3xxQ_DEVICES "H7B3..Q")
set(STM32_H745xx_DEVICES "H745..")
set(STM32_H755xx_DEVICES "H755..")
set(STM32_H747xx_DEVICES "H747..")
set(STM32_H757xx_DEVICES "H757..")
