---
title: 世界的本源是信息？
date: 2023-08-29
slug: physics-information-model
author: HtwoO
categories:
    - 物理
    - 信息论
tags:
    - 胡思乱想
    - 熵
    - 问题
---

最早产生这个想法，是几年前我看了维基百科[信息熵英文词条](https://en.wikipedia.org/wiki/Entropy_(information_theory))的时候，读到了下面一段话：

> In the view of Jaynes (1957), thermodynamic entropy, as explained by statistical mechanics, should be seen as an application of Shannon's information theory: the thermodynamic entropy is interpreted as being proportional to the amount of further Shannon information needed to define the detailed microscopic state of the system, that remains uncommunicated by a description solely in terms of the macroscopic variables of classical thermodynamics, with the constant of proportionality being just the Boltzmann constant.

简单翻译过来：在 Edwin Thompson Jaynes 看来，统计力学／热力学的熵，应该被看作是香农信息理论的应用：可以认为热力学熵与描述该系统（未来）详细微观（粒子）状态所需的信息量成比例，而那个比例常数就是玻尔兹曼常数。

后来我读到了一些关于物理定律和信息理论之间关联的很有意思的文章和讨论：

 - [计算的极限（英文）](https://en.wikipedia.org/wiki/Limits_of_computation)，介绍了计算机信息处理速率、存储密度和数据传输速率上限由一些物理定律来支配。

 - [数据传输速率有极限么？（英文）](https://physics.stackexchange.com/questions/403016/is-there-a-physical-limit-to-data-transfer-rate)，有答案给出了一些具体的数据传输速率上限的计算过程，讨论中的一个示例是在管道中以光速移动的黑洞。著名的[量子质因数分解算法](https://zh.wikipedia.org/wiki/%E7%A7%80%E7%88%BE%E6%BC%94%E7%AE%97%E6%B3%95)作者彼得・秀尔还在这个问题中参加了讨论。

 - [知乎：怎么用国际基本单位来表示字节？](https://www.zhihu.com/question/29660993)，有答案论证为何信息熵无量纲。

 - [为何温度不用焦耳来测量？（英文）](https://physics.stackexchange.com/questions/60830/why-isnt-temperature-measured-in-joules)，有答案提到了在某些情况下是可以的，还有的提到了国际单位制先于统计力学出现，所以我们只是习惯了已有的单位。

 - [假如（热力学）熵是无量纲的（英文）](https://aapt.scitation.org/doi/10.1119/1.19094)，只是一篇论文的摘要，我没有去翻阅论文的内容，不过它说明了这个想法很多人考虑过。

热力学熵和信息熵的关联：
 - 两者的公式极其相似，这里不列出来了，读者去搜索一下就能看到。

 - 两者都可以被认为是无量纲的。热力学温度表示物体内部物质粒子平均动能，是物质内能的一种外在表现，所以我觉得热力学温标开尔文也可以用焦耳来作为单位，热力学熵的单位是 J/K ，焦耳每开尔文，是能量的比值，应该是无量纲的。

我们知道信息熵是描述不确定性的，一个系统的熵值越大，它（未来）的状态就越不好确定，描述它的状态需要的信息量就越大。我们以最简单的一个假想系统、一个死的系统（也就是说它不会再发生任何状态变化）为例，除了对系统当前状态的描述之外，我们无需任何新的信息来描述它。

另一个很知名的假想系统、一些物理模型预测的宇宙终结状态——[热寂](https://zh.wikipedia.org/wiki/%E7%83%AD%E5%AF%82)，是一个极其无序、熵值很高的状态，宇宙就像一大锅粒子汤，其中的粒子状态几乎完全随机，意味着某个粒子的下一状态极其难以确定，也就是需要比较大的数字才能描述它的状态。这里有个很有意思的反直觉的事实，传统阴极射线管（ CRT ）电视显示雪花点画面状态的时候，画面信息量是比显示某个人类能识别的图案状态时更大的。

再后来，大概一年多前，我读到物理学家约翰·惠勒（ John Archibald Wheeler ）之前有过相似的想法，还写了一篇后来被称为 It from Bit （存在源于比特？）的[论文（英文）](https://jawarchive.files.wordpress.com/2012/03/informationquantumphysics.pdf)。

在[这篇文章（英文）](https://plus.maths.org/content/it-bit)中，作者 Rachel Thomas 说安东·塞林格不同意惠勒的激进观点，对于「我们能否说现实世界就是信息，也就是它们是一模一样的？」，塞林格说「不，两个概念我们都需要，不过要严格区分两者是相当困难的……」。大物理学家都分不清现实世界和信息的区别，也许就像文章中说的，一百多年前爱因斯坦说我们无法把时间和空间分开，而要把他们合称为时空来一起解释。（安东·塞林格是潘建伟的导师，因在量子信息论的研究而获得 2022 年诺贝尔物理学奖。）

物理学界普遍认为[超光速](https://zh.wikipedia.org/zh-cn/%E8%B6%85%E5%85%89%E9%80%9F)传播不是不能存在，只是超光速传播的那个东东不能携带信息（或能量）。信息在基本物理定律中这么重要，不会这么巧吧？ 😄

如果这个模型是合理的，就是说，信息可能是比能量或热更为根本的概念，那么 [xkcd 435](https://xkcd.com/435/) 漫画里，物理的右边可以加进信息论，可以认为信息论是元宇宙的基础理论 😄

信息可以用数字来编码，无量纲物理量是没有单位的，也就是说描述那个物理量的只有数字，所以如果世界本源是信息的话，描述世界的根本规律只用数字就可以了。通过把物理定律根据形式逻辑的规则编码成计算机程序，我们可以在计算机中创建物理模型的逻辑描述、进行状态变换，用来模拟和研究现实世界，和创造新的逻辑世界。人类创造的经济和法律规则就是纯粹的逻辑世界，它们是我所理解的元宇宙，是当今影响最为显著的逻辑世界的典型，不过它们有时候也会和现实世界产生冲突。在出现冲突的情况下，逻辑系统的论证要重新回归到现实世界的物理事实，毕竟事实是（与现实世界交互的）逻辑系统的基础。

根据这个假想的模型，将来我们也许能统一物理和计算理论，我们可以把物理定律理解成是对信息论允许存在的世界的约束，每个物理定律对现实世界的（粒子、波、时空等）物理实体应该怎样运作给定一组约束。「计算」的极限（比如计算系统的能耗）是受物理定律支配的，只是现阶段信息技术的性能指标距离已知物理理论上限还比较远。

当然，同一个物理规律，往往可以从不同的角度，用不同的模型来描述，比如原子、波、粒子和时空等实体都是用来描述物理规律的模型，信息熵和热力学熵有很多相似之处，也许以后物理学家们能总结出从信息论角度来描述的物理定律／现实世界。

2023 年的今天，写作本文过程中，我才发现在（热力学）[熵的英文词条](https://en.wikipedia.org/wiki/Entropy) 中，有个「如何理解熵」段落，其中的「信息论」子段落，有这么一句话，「大部分研究者认为信息熵和热力学熵直接与同一个概念关联，也有其他研究者说他们不一样」，并在前半句后面给出了好几个引用资料，后半句的才给了一个。这反而让我感觉奇怪了，难道这个想法变成学术界主流了么？如果是这样，这反而让我想传播这个想法的动机没那么强烈了 ;-)

本文只是记录自己想法的来源，和基于这个假设的一些有意思的推断。
