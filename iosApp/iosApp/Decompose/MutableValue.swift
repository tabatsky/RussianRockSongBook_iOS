//
//  MutableValue.swift
//  iosApp
//
//  Created by User on 24.04.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import shared

func mutableValue<T: AnyObject>(_ initialValue: T) -> MutableValue<T> {
    return MutableValueBuilderKt.MutableValue(initialValue: initialValue) as! MutableValue<T>
}
