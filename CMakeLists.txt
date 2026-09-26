cmake_minimum_required(VERSION 3.16)
project(ProCalculator VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

# MACOSX_BUNDLE tells CMake to make an .app folder!
qt_add_executable(ProCalculator MACOSX_BUNDLE
    main.cpp
    calculator.h
    calculator.cpp
    qml.qrc
)

target_link_libraries(ProCalculator PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)
