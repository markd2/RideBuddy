import Foundation

// suggested by SqueakyToy.
//  c.f. https://quickbirdstudios.com/blog/swift-dependency-injection-service-locators/

protocol Resolver {
    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType
    func maybeResolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType?
}

protocol ServiceFactory {
    associatedtype ServiceType
    func resolve(_ resolver: Resolver) -> ServiceType
}

// It should allow us to register new factories for a certain type
// It should store ServiceFactory instances
// It should be used as a Resolver for any stored type
//
// To be able to store instances of ServiceFactory classes in a
// type-safe manner we would need to be able to have variadic generics
// implemented in Swift.  #lolswift none for use
// In the meantime, we need to eliminate the generic type using a type
//  erased version called AnyServiceFactory.


/// Adopt this protocol and then the service locator can instantiate your 
/// instances and give you the resolver so it can get its dependencies
protocol ServiceTypeResolvable {
    init(resolver: Resolver)
}

struct Container: Resolver {
    let factories: [AnyServiceFactory]

    init() {
        self.factories = []
    }

    private init(factories: [AnyServiceFactory]) {
        self.factories = factories
    }

    func register<T>(_ type: T.Type, instance: T) -> Container {
        return register(type) { _ in instance }
    }

    func register<ServiceType: ServiceTypeResolvable>(_ type: ServiceType.Type) -> Container  {
        register(type, { resolver in
                ServiceType(resolver: resolver)
            })
    }

    func register<ServiceType>(_ type: ServiceType.Type, 
        _ factory: @escaping (Resolver) -> ServiceType) -> Container {
        assert(!factories.contains(where: { $0.supports(type) }))

        let newFactory = BasicServiceFactory<ServiceType>(type, factory: { resolver in
                factory(resolver)
            })
        return .init(factories: factories + [AnyServiceFactory(newFactory)])
    }

    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }

    func maybeResolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType? {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            return nil
        }
        return factory.resolve(self)
    }

}

// Type-erased factory thingie
final class AnyServiceFactory {
    private let _resolve: (Resolver) -> Any
    private let _supports: (Any.Type) -> Bool

    init<T: ServiceFactory>(_ serviceFactory: T) {
        self._resolve = { resolver -> Any in
            serviceFactory.resolve(resolver)
        }
        self._supports = { $0 == T.ServiceType.self }
    }

    func resolve<ServiceType>(_ resolver: Resolver) -> ServiceType {
        return _resolve(resolver) as! ServiceType
    }

    func supports<ServiceType>(_ type: ServiceType.Type) -> Bool {
        return _supports(type)
    }
}

struct BasicServiceFactory<ServiceType>: ServiceFactory {
    private let factory: (Resolver) -> ServiceType

    init(_ type: ServiceType.Type, factory: @escaping (Resolver) -> ServiceType) {
        self.factory = factory
    }

    func resolve(_ resolver: Resolver) -> ServiceType {
        return factory(resolver)
    }
}

