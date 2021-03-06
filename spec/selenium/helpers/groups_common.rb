require File.expand_path(File.dirname(__FILE__) + '/../common')

def seed_users(count)
  count.times do |n|
    @student = User.create!(:name => "Test Student #{n+1}")
    @course.enroll_student(@student).accept!
  end
end

# Creates group sets equal to groupset_count and groups within each group set equal to groups_per_set
def seed_groups(groupset_count, groups_per_set)
  @group_category = []
  @testgroup = []
  groupset_count.times do |n|
    @group_category << @course.group_categories.create!(:name => "Test Group Set #{n+1}")

    groups_per_set.times do |i|
      @testgroup << @course.groups.create!(:name => "Test Group #{i+1}", :group_category => @group_category[n])
    end
  end
end

# Sets up groups and users for testing. Default is 1 user, 1 groupset, and 1 group per groupset.
def group_test_setup(user_count = 1, groupset_count = 1, groups_per_set = 1)
  seed_users(user_count)
  seed_groups(groupset_count, groups_per_set)
end

def add_user_to_group(user,group)
  group.add_user user
  group.save!
end

def create_default_student_group(group_name = "Windfury")
  fj("#groupName").send_keys(group_name.to_s)
  fj('button.confirm-dialog-confirm-btn').click
  wait_for_ajaximations
end

def create_group_and_add_all_students(group_name = "Windfury")
  fj("#groupName").send_keys(group_name.to_s)
  students = ffj(".checkbox")
  students.each do |student|
    student.click
  end
  fj('button.confirm-dialog-confirm-btn').click
  wait_for_ajaximations
end

def create_group_with_student(params={})
  default_params = {
      :group_name => "Windfury",
      :enroll_student_count => 0,
      :add_student => true
  }
  params = default_params.merge(params)

  category1 = @course.group_categories.create!(:name => "category 1")
  category1.configure_self_signup(true, false)
  category1.save!
  g1 = @course.groups.create!(:name => params[:group_name], :group_category => category1)

  if params[:add_student] == true
    g1.add_user @student
    g1.leader = @student
    g1.save!
  end

  seed_users(params[:enroll_student_count])
end

def create_group_with_student_with_a_teacher(group_name = "Windfury", enroll_student_count = 0)
  @student = User.create!(:name => "Test Student 1")
  @course.enroll_student(@student).accept!

  g1 = @course.groups.create!(:name => group_name)
  g1.add_user @student
  g1.save!

  enroll_student_count.times do |n|
    @student = User.create!(:name => "Test Student #{n+2}")
    @course.enroll_student(@student).accept!

    g1.add_user @student
    g1.save!
  end

  return g1
end

def delete_group
  f(".icon-settings").click
  wait_for_animations

  fln('Delete').click

  driver.switch_to.alert.accept
  wait_for_animations
end