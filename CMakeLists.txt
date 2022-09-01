cmake_minimum_required(VERSION 3.15)

project(haruna LANGUAGES CXX)

# 自动添加CMAKE_CURRENT_BINARYDIR和CMAKE_CURRENT_SOURCE_DIR到当前处理
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED)
add_definitions(-D_UNICODE) # CMake生成Unicode版本
find_package(ECM 1.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(KDEInstallDirs)

find_package(Qt5 COMPONENTS
    Widgets
    Core
    Quick
    QuickControls2
)

set(${PROJECT_NAME}_SRC
    src/main.cpp
    src/qml.qrc
)

add_executable(${PROJECT_NAME} ${${PROJECT_NAME}_SRC})
#target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Widgets
    Qt5::Core
    Qt5::Quick
    Qt5::QuickControls2    
    mpv
    mediainfo
)