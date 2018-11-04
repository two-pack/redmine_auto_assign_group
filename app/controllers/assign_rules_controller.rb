class AssignRulesController < ApplicationController
  layout 'admin'

  before_action :require_admin

  def index; end

  def new
    @group = Group.find(params[:group_id])
    @rule = AssignRule.new
  end

  def edit
    @group = Group.find(params[:group_id])
    @rule = AssignRule.find(params[:id])
  end

  def update
    @rule = AssignRule.find(params[:id])
    @rule.safe_attributes = permitted_params
    if @rule.save
      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_update)
          redirect_to edit_group_path(Group.find(params[:group_id]), tab: :rules)
        end
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html do
          @group = Group.find(@rule.group_id)
          render action: 'edit'
        end
        format.js { head 422 }
      end
    end
  end

  def create
    @rule = AssignRule.new
    @rule.safe_attributes = permitted_params
    if @rule.save
      flash[:notice] = l(:notice_successful_create)
      group = Group.find(@rule.group_id)
      if params[:continue]
        redirect_to new_group_assign_rule_path(group)
      else
        redirect_to edit_group_path(group, tab: :rules)
      end
    else
      @group = Group.find(@rule.group_id)
      render action: 'new'
    end
  end

  def destroy
    AssignRule.find(params[:id]).destroy
    redirect_to edit_group_path(Group.find(params[:group_id]), tab: :rules)
  rescue
    flash[:error] = l(:error_raag_unable_delete_rule)
    redirect_to edit_group_path(Group.find(params[:group_id]), tab: :rules)
  end

  private

  def permitted_params
    params.require(:assign_rule).permit(
      :group_id, :name, :mail, :firstname, :lastname, :positon
    )
  end
end
