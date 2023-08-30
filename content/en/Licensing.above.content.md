---
title: Licensing above the Code/Content
date: 2023-08-30
slug: content-licensing
author: HtwoO
categories:
    - Life
    - Technology
tags:
    - Licensing
---

This idea first came to me when I was thinking about how to make free (as in freedom) or open software more sustainable. And later I read more and more news about free/open source developers' struggle maintaining what they created.

## The problem
A lot of organizations are not paying for the free/open source tools/content they use. Examples can be seen in the following list:

 - [Apple support](https://twitter.com/AppleSupport/status/1461330383425970180) redirecting issues with macOS shipped [curl](https://curl.se/) to [curl developer](https://daniel.haxx.se/blog/2021/11/18/free-apple-support/). If you don't want to go into the twitter link, content of Apple support's twitt is here, "Thanks for contacting us. To get help with this issue, please reach out to Curl: https://curl.se/gethelp.html".

 - Developer of `color.js/faker.js` made deliberate malfunction changes to these projects to call for financial support. Thousands of other projects were affected. See discussion [where](https://github.com/Marak/colors.js/issues/285) the accident happened. Archived [discussion](https://web.archive.org/web/20210704022108/https://github.com/Marak/faker.js/issues/1046) of the inccident. [Other](https://borncity.com/win/2022/01/10/entwickler-sabotieren-open-source-colors-js-und-faker-js-module-in-npm-betrifft-tausende-projekte/) [Report](https://www.theregister.com/2022/01/10/npm_fakerjs_colorsjs/) about the inccident.

 - [Baidu's](https://en.wikipedia.org/wiki/Baidu_Baike) and [Bytedance's](https://en.wikipedia.org/wiki/Baike.com) online encyclopedia, both have records of crawling content from Wikipedia. I knew that because some pages I created on Wikipedia were copied. These companies use the content they copy from copyleft websites and release them in a non-free license, and profit from those content.

 - And recently, a `core-js` developer is having [difficulties making ends meet](https://github.com/zloirock/core-js/blob/master/docs/2023-02-14-so-whats-next.md).

Comments from issues reported to the project in the second example:

 - "Does this mean Amazon is including code from external sources without reviewing it?", at https://github.com/aws/aws-cdk/issues/18323
 - "Why you didn't fund marak?" from https://github.com/aws/aws-cdk/issues/18322

I'm not presenting these to endorse/justify any party in these events. But we need to admit there are issues with the current situation. In a lot of these events, we see many people point to xkcd's [_Dependency_](https://xkcd.com/2347/) webcomic, which is quite true for many components in our computing environment.

## My thoughts
I have read comment on twitter asking "Should countries subsidize open source like they often do with Science or Climate Change?". My answer is that we may not need to, if we have a better licensing model.

In preventing companies from benefitting from but not contributing back to free/open source community, GNU Affero General Public License (AGPL) and GPLv3 are better options to LGPL, Apache, BSD or MIT licenses. Someone even [called](https://lukesmith.xyz/articles/why-i-use-the-gpl-and-not-cuck-licenses/) permissive licenses like BSD or MIT "Cuck Licenses".

But I think we can even do better than AGPL/GPLv3, by introducing a new licensing model that reflects "with great power comes great responsibility". Big companies with billions of valuation surely have greater power over individual devolopers, so they should bare more responsibilities in making our society better. Since I'm not a lawer, the following are just suggestions, but I think lawers at Free Software Foundation should consider these suggestions.

## A new licensing model
Instead of digging into technical details about how code/content are used like [linking](https://en.wikipedia.org/wiki/Linker_(computing)) or [inter-process-communication](https://en.wikipedia.org/wiki/Inter-process_communication) (IPC), et cetera, I think we should focus on various criteria such as number of employee/user of the organizations, number of employees having access to the free/open source components or other measurements that organizations advertise about their success, either to attract investors, or to demostrate that they have great achievements. Licenses should be created which required payment from client organizations, and the amount of payment will be derived from those measurements. Let's call these Spider-Man licenses in this article.

With Spider-Man licenses, we can design simple mathematical functions to make payment increase smoothly when the impact of the code/content increase (eg. no sudden increase/drop when measurements reach a certain figure), and possibly capped when the figure is very large. In any case, the amount of payment can be discussed. When the code/content reach a phase of tens of millions of users, payment for the code/content should allow the owners of the code/content to setup an organization (and hire people) to work full time on helping their users, independent of other (for-profit) companies.

I will give several rationales here on why/how these can be implemented.

 - Usually, when a project is small, there may only be a few users, so the cost of maintaining/upgrading the code/content is small. At this stage, whether or not the project is free/open source may not matter a lot.

 - As the project grows, the need for support increase, the owner/community of the project can setup a non-profit organization to handle issues reported by users and to receive financial support, at this phase working part time and receiving small payment for the project shall still be feasible for the owner.

 - When the project is huge, like, if it is serving tens of millions of people. Mandates to make the code/content open should be implemented, like in the cases of Alipay/E-CNY/WeChat/QQ in China, to allow improvement from competent contributors, and to allow security audit of the code/content by registered parties.

 - Filtering on content distribution platform, such as NPM, based on licenses of projects, should be implemented, so that when users introduce dependencies and search on the platform, projects using Spider-Man licenses would not be visible if companies policy do not allow these licenses. So those companies which want to profit from but not contributing back are aware they need to implement and maintain their own components to prevent potential legal issues.

One might argue that Spider-Man licenses are not enforceable. Like in the case of AGPL, outside party may not be able to peek into the code of a service in a legal way. I would admit that this may be true. But unless companies
 - have perfect security operational practices,
 - have no ethical employee to help expose the infringement,
 - are not saving any source code/content that can be traced (good luck on them),

facts about the company using open components will eventually be known to ousiders. So Spider-Man licenses are as good as AGPL on this ground.

Spider-Man licensing model can even prevent a logical circumvention. In such a case, a company can use an open source  project by wrapping it in close source components, making it a "brain in a vat" of the closed parts. Although in such a case, what lawers argue about would be the definition of "use".

If Wikimedia foundation is using Spider-Man licensing model, millions of users won't see that big banner asking for suppport at year end. And yes, financial flow for Spider-Man licensed free/open source projects should be open for audit, just like government budgets should have been.

## Afterword

I choose this title as an analogy to Leslie Lamport's "Thinking above the Code" [talk](https://www.youtube.com/watch?v=-4Yp3j_jk8Q).

Just heard about [Promodbus license](https://libmodbus.org/promodbus-license/) used by [libmodbus](https://libmodbus.org), I think it's a good attempt.

Fun fact: I heard from people in a tech discussion group (where some may just be Tencent software engineeers) that, the protocol QQ used was badly designed, and the legacy code used there, is a pile of shit (or 屎山 in Chinese :lol:-), even if it is opened, developers may not like to work on it ;-)
