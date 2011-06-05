# Here we start to piece together the top of the object model hierarchy.
# We can't just declare these bits in CORE.setting with normal Perl 6
# syntax due to circularity issues. Note that we don't compose any of
# these - which is equivalent to a { ... } body.
#
# One particular circularity we break here is that you can't have
# inheritance in Perl 6 without traits, but that needs multiple
# dispatch, which can't function without some a type hierarchy in
# place. It also needs us to be able to declare a signature with
# parameters and a code objects with dispatchees, which in turn need
# attributes. So, we set up quite a few bits in here, though the aim
# is to keep it "lagom". :-)
#
# Note that we do pay the cost of doing this every startup *for now*.
# In the medium term, we'll have bounded serialization. Then we'll likley
# do all of this in a BEGIN block and it'll get serialized and thus loading
# it will just be deserialization - hopefully! :) Note that said BEGIN will
# likely end up being in the setting itself, not in here, also.

# Bootstrapping Attribute class that we eventually replace with the read
# one.
my class BOOTSTRAPATTR {
    has $!name;
    has $!type;
    has $!box_target;
    method name() { $!name }
    method type() { $!type }
    method box_target() { $!box_target }
    method compose($obj) { }
}

# class Mu { ... }
my stub Mu metaclass Perl6::Metamodel::ClassHOW { ... };
pir::set_binder_top_type__vP(Mu);

# XXX Move out of bootstrap when possible.
Mu.HOW.add_parrot_vtable_mapping(Mu, 'get_bool',
    sub ($self) { $self.Bool() });
Mu.HOW.publish_parrot_vtable_mapping(Mu);

# class Any is Mu { ... }
my stub Any metaclass Perl6::Metamodel::ClassHOW { ... };
Any.HOW.add_parent(Any, Mu);

# class Cool is Any { ... }
my stub Cool metaclass Perl6::Metamodel::ClassHOW { ... };
Cool.HOW.add_parent(Cool, Any);

# class Attribute is Cool {
#     has str $!name;
#     has int $!rw;
#     has int $!has_accessor;
#     has $!type;
#     has $!container_descriptor;
#     has $!auto_viv_container;
#     has $!build_closure;
#     ... # Uncomposed
# }
my stub Attribute metaclass Perl6::Metamodel::ClassHOW { ... };
Attribute.HOW.add_parent(Attribute, Cool);
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!name>, :type(str)));
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!rw>, :type(int)));
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!has_accessor>, :type(int)));
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!type>, :type(Mu)));
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!container_descriptor>, :type(Mu)));
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!auto_viv_container>, :type(Mu)));
Attribute.HOW.add_attribute(Attribute, BOOTSTRAPATTR.new(:name<$!build_closure>, :type(Mu)));
Attribute.HOW.publish_parrot_vtable_mapping(Attribute);

# XXX Need new and accessor methods for Attribute in here for now.
Attribute.HOW.add_method(Attribute, 'new',
    sub ($self, :$name, :$type, :$container_descriptor, :$has_accessor, *%other) {
        my $attr := pir::repr_instance_of__PP($self);
        pir::repr_bind_attr_str__vPPsS($attr, Attribute, '$!name', $name);
        pir::setattribute__vPPsP($attr, Attribute, '$!type', $type);
        pir::repr_bind_attr_int__vPPsI($attr, Attribute, '$!has_accessor', $name);
        pir::setattribute__vPPsP($attr, Attribute, '$!container_descriptor', $container_descriptor);
        if pir::exists(%other, 'auto_viv_container') {
            pir::setattribute__vPPsP($attr, Attribute, '$!auto_viv_container',
                %other<auto_viv_container>);
        }
        $attr
    });
Attribute.HOW.add_method(Attribute, 'name', sub ($self) {
        pir::repr_get_attr_str__SPPs($self, Attribute, '$!name');
    });
Attribute.HOW.add_method(Attribute, 'type', sub ($self) {
        pir::getattribute__PPPs($self, Attribute, '$!type');
    });
Attribute.HOW.add_method(Attribute, 'container_descriptor', sub ($self) {
        pir::getattribute__PPPs($self, Attribute, '$!container_descriptor');
    });
Attribute.HOW.add_method(Attribute, 'auto_viv_container', sub ($self) {
        pir::getattribute__PPPs($self, Attribute, '$!auto_viv_container');
    });
Attribute.HOW.add_method(Attribute, 'has_accessor', sub ($self) {
        pir::perl6_booleanize__PI(
            pir::repr_get_attr_int__IPPs($self, Attribute, '$!has_accessor'));
    });
Attribute.HOW.add_method(Attribute, 'rw', sub ($self) {
        pir::perl6_booleanize__PI(
            pir::repr_get_attr_int__IPPs($self, Attribute, '$!rw'));
    });
Attribute.HOW.add_method(Attribute, 'set_rw', sub ($self) {
        pir::repr_bind_attr_int__vPPsi(pir::perl6_decontainerize__PP($self),
            Attribute, '$!rw', 1);
        pir::perl6_booleanize__PI(1)
    });
Attribute.HOW.add_method(Attribute, 'set_build_closure', sub ($self, $closure) {
        pir::setattribute__0PPsP(pir::perl6_decontainerize__PP($self),
            Attribute, '$!build_closure', $closure);
    });

# class Signature is Cool {
#    has $!params;
#    has $!returns;
#     ... # Uncomposed
# }
my stub Signature metaclass Perl6::Metamodel::ClassHOW { ... };
Signature.HOW.add_parent(Signature, Cool);
Signature.HOW.add_attribute(Signature, BOOTSTRAPATTR.new(:name<$!params>, :type(Mu)));
Signature.HOW.add_attribute(Signature, BOOTSTRAPATTR.new(:name<$!returns>, :type(Mu)));

# class Parameter is Cool {
#     has str $!variable_name
#     has $!named_names
#     has $!type_captures
#     has int $!flags
#     has $!nominal_type
#     has $!post_constraints
#     has str $!coerce_to
#     has $!sub_signature
#     has $!default_closure
#     has $!container_descriptor;
#     ... # Uncomposed
# }
my stub Parameter metaclass Perl6::Metamodel::ClassHOW { ... };
Parameter.HOW.add_parent(Parameter, Cool);
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!variable_name>, :type(str)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!named_names>, :type(Mu)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!type_captures>, :type(Mu)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!flags>, :type(int)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!nominal_type>, :type(Mu)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!post_constraints>, :type(Mu)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!coerce_to>, :type(str)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!sub_signature>, :type(Mu)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!default_closure>, :type(Mu)));
Parameter.HOW.add_attribute(Parameter, BOOTSTRAPATTR.new(:name<$!container_descriptor>, :type(Mu)));

# class Code is Cool {
#     has $!do;                # Low level code object
#     has $!signature;         # Signature object
#     has $!dispatchees;       # If this is a dispatcher, the dispatchee list.
#     has $!dispatcher_info;   # Stash for any extra dispatcher info.
#     ... # Uncomposed
# }
my stub Code metaclass Perl6::Metamodel::ClassHOW { ... };
Code.HOW.add_parent(Code, Cool);
Code.HOW.add_attribute(Code, BOOTSTRAPATTR.new(:name<$!do>, :type(Mu)));
Code.HOW.add_attribute(Code, BOOTSTRAPATTR.new(:name<$!signature>, :type(Mu)));
Code.HOW.add_attribute(Code, BOOTSTRAPATTR.new(:name<$!dispatchees>, :type(Mu)));
Code.HOW.add_attribute(Code, BOOTSTRAPATTR.new(:name<$!dispatcher_info>, :type(Mu)));

# Need to actually run the code block. Also need this available before we finish
# up the stub.
Code.HOW.add_parrot_vtable_handler_mapping(Code, 'invoke', '$!do');
Code.HOW.publish_parrot_vtable_handler_mapping(Code);
Code.HOW.publish_parrot_vtable_mapping(Code);

# class Block is Code { ... }
my stub Block metaclass Perl6::Metamodel::ClassHOW { ... };
Block.HOW.add_parent(Block, Code);
Block.HOW.publish_parrot_vtable_handler_mapping(Block);
Block.HOW.publish_parrot_vtable_mapping(Block);

# class Routine is Block { ... }
my stub Routine metaclass Perl6::Metamodel::ClassHOW { ... };
Routine.HOW.add_parent(Routine, Block);
Routine.HOW.publish_parrot_vtable_handler_mapping(Routine);
Routine.HOW.publish_parrot_vtable_mapping(Routine);

# class Sub is Routine { ... }
my stub Sub metaclass Perl6::Metamodel::ClassHOW { ... };
Sub.HOW.add_parent(Sub, Routine);
Sub.HOW.publish_parrot_vtable_handler_mapping(Sub);
Sub.HOW.publish_parrot_vtable_mapping(Sub);

# class Method is Routine { ... }
my stub Method metaclass Perl6::Metamodel::ClassHOW { ... };
Method.HOW.add_parent(Method, Routine);
Method.HOW.publish_parrot_vtable_handler_mapping(Method);
Method.HOW.publish_parrot_vtable_mapping(Method);

# class Str is Cool {
#     has str $!value is box_target;
#     ...
# }
my stub Str metaclass Perl6::Metamodel::ClassHOW { ... };
Str.HOW.add_parent(Str, Cool);
Str.HOW.add_attribute(Str, BOOTSTRAPATTR.new(:name<$!value>, :type(str), :box_target(1)));

# class Int is Cool {
#     has int $!value is box_target;
#     ...
# }
my stub Int metaclass Perl6::Metamodel::ClassHOW { ... };
Int.HOW.add_parent(Int, Cool);
Int.HOW.add_attribute(Int, BOOTSTRAPATTR.new(:name<$!value>, :type(int), :box_target(1)));

# class Num is Cool {
#     has num $!value is box_target;
#     ...
# }
my stub Num metaclass Perl6::Metamodel::ClassHOW { ... };
Num.HOW.add_parent(Num, Cool);
Num.HOW.add_attribute(Num, BOOTSTRAPATTR.new(:name<$!value>, :type(num), :box_target(1)));

# class Scalar is Any {
#     has $!descriptor;
#     has $!value;
#     ...
# }
my stub Scalar metaclass Perl6::Metamodel::ClassHOW { ... };
Scalar.HOW.add_parent(Scalar, Any);
Scalar.HOW.add_attribute(Scalar, BOOTSTRAPATTR.new(:name<$!descriptor>, :type(Mu)));
Scalar.HOW.add_attribute(Scalar, BOOTSTRAPATTR.new(:name<$!value>, :type(Mu)));
pir::set_scalar_container_type__vP(Scalar);

# Scalar needs to be registered as a container type.
pir::set_container_spec__vPPsP(Scalar, Scalar, '$!value', pir::null__P());

# XXX Quick and dirty Bool. Probably done by EnumHOW in the end.
my stub Bool metaclass Perl6::Metamodel::ClassHOW { ... };
Bool.HOW.add_parent(Bool, Cool);
Bool.HOW.add_attribute(Bool, BOOTSTRAPATTR.new(:name<$!value>, :type(int)));
Bool.HOW.add_parrot_vtable_mapping(Bool, 'get_bool',
    sub ($self) { pir::repr_get_attr_int__IPPs($self, Bool, '$!value') });
Bool.HOW.publish_parrot_vtable_mapping(Bool);
    
# Set up Stash type, using a Parrot hash under the hood for storage.
my stub Stash metaclass Perl6::Metamodel::ClassHOW { ... };
Stash.HOW.add_parent(Stash, Cool);
Stash.HOW.add_attribute(Stash, BOOTSTRAPATTR.new(:name<$!symbols>, :type(Mu)));
Stash.HOW.add_parrot_vtable_handler_mapping(Stash, 'get_pmc_keyed', '$!symbols');
Stash.HOW.add_parrot_vtable_handler_mapping(Stash, 'get_pmc_keyed_str', '$!symbols');
Stash.HOW.add_parrot_vtable_handler_mapping(Stash, 'set_pmc_keyed', '$!symbols');
Stash.HOW.add_parrot_vtable_handler_mapping(Stash, 'set_pmc_keyed_str', '$!symbols');
Stash.HOW.add_parrot_vtable_handler_mapping(Stash, 'get_iter', '$!symbols');
Stash.HOW.publish_parrot_vtable_handler_mapping(Stash);

# Set this Stash type for the various types of package.
Perl6::Metamodel::PackageHOW.set_stash_type(Stash);
Perl6::Metamodel::ModuleHOW.set_stash_type(Stash);
Perl6::Metamodel::NativeHOW.set_stash_type(Stash);
Perl6::Metamodel::ClassHOW.set_stash_type(Stash);

# Give everything we've set up so far a Stash.
Perl6::Metamodel::ClassHOW.add_stash(Mu);
Perl6::Metamodel::ClassHOW.add_stash(Any);
Perl6::Metamodel::ClassHOW.add_stash(Cool);
Perl6::Metamodel::ClassHOW.add_stash(Attribute);
Perl6::Metamodel::ClassHOW.add_stash(Signature);
Perl6::Metamodel::ClassHOW.add_stash(Parameter);
Perl6::Metamodel::ClassHOW.add_stash(Code);
Perl6::Metamodel::ClassHOW.add_stash(Block);
Perl6::Metamodel::ClassHOW.add_stash(Routine);
Perl6::Metamodel::ClassHOW.add_stash(Sub);
Perl6::Metamodel::ClassHOW.add_stash(Method);
Perl6::Metamodel::ClassHOW.add_stash(Str);
Perl6::Metamodel::ClassHOW.add_stash(Int);
Perl6::Metamodel::ClassHOW.add_stash(Num);
Perl6::Metamodel::ClassHOW.add_stash(Scalar);
Perl6::Metamodel::ClassHOW.add_stash(Bool);
Perl6::Metamodel::ClassHOW.add_stash(Stash);

# Bool::False and Bool::True.
# XXX Really bad because they're not types. Yup, need EnumHOW...
my $false := pir::repr_instance_of__PP(Bool);
pir::repr_bind_attr_int__vPPsI($false, Bool, '$!value', 0);
(Bool.WHO)<False> := $false;
my $true := pir::repr_instance_of__PP(Bool);
pir::repr_bind_attr_int__vPPsI($true, Bool, '$!value', 1);
(Bool.WHO)<True> := $true;
pir::perl6_set_bools__vPP($false, $true);

# Build up EXPORT::DEFAULT.
my module EXPORT {
    our module DEFAULT {
        $?PACKAGE.WHO<Mu>        := Mu;
        $?PACKAGE.WHO<Any>       := Any;
        $?PACKAGE.WHO<Cool>      := Cool;
        $?PACKAGE.WHO<Attribute> := Attribute;
        $?PACKAGE.WHO<Signature> := Signature;
        $?PACKAGE.WHO<Parameter> := Parameter;
        $?PACKAGE.WHO<Code>      := Code;
        $?PACKAGE.WHO<Block>     := Block;
        $?PACKAGE.WHO<Routine>   := Routine;
        $?PACKAGE.WHO<Sub>       := Sub;
        $?PACKAGE.WHO<Method>    := Method;
        $?PACKAGE.WHO<Str>       := Str;
        $?PACKAGE.WHO<Int>       := Int;
        $?PACKAGE.WHO<Num>       := Num;
        $?PACKAGE.WHO<Stash>     := Stash;
        $?PACKAGE.WHO<Scalar>    := Scalar;
        $?PACKAGE.WHO<Bool>      := Bool;
        $?PACKAGE.WHO<ContainerDescriptor> := Perl6::Metamodel::ContainerDescriptor;
    }
}
