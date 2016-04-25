class Ability
  include CanCan::Ability

  def initialize(user)
    if user                   # allow access to dashboard
      can :read, :all
      can :update, User, id: user.id  # allows you to edit your own user account
      can :dashboard

      if user.has_role?(:admin)
        can :manage, :all
      elsif user.has_role? :superadmin
        can :manage, :all             # allow superadmins to do anything
      elsif user.has_role? :manager
        #TODO: ADD Dinamic models to manager 
        can :manage, [ Setup::Connection, Setup::Flow, Setup::DataType, Setup::Webhook, Setup::Event ]
      end
    end

  end
end
