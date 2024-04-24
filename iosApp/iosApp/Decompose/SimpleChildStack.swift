//
//  SimpleChildStack.swift
//  iosApp
//
//  Created by User on 24.04.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import shared

func simpleChildStack<T : AnyObject>(_ child: T) -> Value<ChildStack<AnyObject, T>> {
    return mutableValue(
        ChildStack(
            configuration: "config" as AnyObject,
            instance: child
        )
    )
}
