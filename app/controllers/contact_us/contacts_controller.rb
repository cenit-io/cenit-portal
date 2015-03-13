class ContactUs::ContactsController < ApplicationController

  def create
    @contact = ContactUs::Contact.new(params[:contact_us_contact])

    if @contact.save
      redirect_to(ContactUs.success_redirect || '/', :notice => t('contact_us.notices.success'))
    else
      flash[:error] = t('contact_us.notices.error')
      render_new_page
    end
  end

  def new
    @contact = ContactUs::Contact.new
    @body_id = 'contact-us'
  end

end
