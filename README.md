# 中国科学院大学 计算机组成原理实验课程
# "Five projects to better understand key principles of computer systems", UCAS Spring 2017 Session
本实验课程采用FPGA开发板（ZyPi）完成，分为五个子实验。
Note: Due to copyright reasons, slides will not be uploaded

## 实验项目0 FPGA及工具开发流程
见`Project 0`目录下相关文件。
### 实验项目0简介
跑马灯——循环点亮开发板上的8个LED灯，需要通过计时器保证LED灯的闪烁时间。
## 实验项目1 基本部件单元设计（寄存器堆与ALU）
见`Project 1`目录下相关文件。
### 额外提示
 - `reg_file`模块里面的复位信号`rst`为高电平同步复位。
 - `alu`和`reg_file`模块的端口信号名称不能做任何修改（包括不能修改大小写），但是`alu`模块各端口的信号类型可以在模块内根据需要自行定义类型（如`reg`或`wire`）。为避免混淆，删除了框架工程`project1_student.zip`中`alu`模块`Result`信号的`reg`类型定义；如需将`Result`等信号定义为`reg`类型，请在模块内部进行声明
 - `Zero`标志位在非加减法操作时，结果未定义。
 - 注意编码规范并写好代码注释。
## 实验项目2 单周期处理器
见`Project 2`目录下相关文件。
### 额外提示
 - 本次实验开始，采用“阶段提交”的方式开展实验任务。
