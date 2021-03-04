---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.10.2
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

# Concurrency

**Goal: No _raw_ synchronization**

## Definitions

> _Concurrency_ is when tasks start, run, and complete in overlapping time periods

> _Parallelism_ is when two or more tasks execute simultaneously

- Threads enable concurrency
- Processor cores enable parallelism


## Motivation

- Better performance can be achieved through parallelism
- Better interactivity, and reduced latency, can be achieved through concurrency


## Synchronization Primitive

- Mutex
- Lock
- Condition Variable
- Semaphore
- Memory Fence
